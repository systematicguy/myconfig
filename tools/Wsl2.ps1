. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoRoot\windows\MsiTools.ps1
. $RepoRoot\windows\Downloader.ps1

# https://learn.microsoft.com/en-us/windows/wsl/install-manual
# https://github.com/microsoft/WSL/issues/3369
# https://learn.microsoft.com/en-us/windows/wsl/install-on-server

$wslKernelUpdater = "wsl_update_x64.msi"
$wslKernelUpdaterUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/$wslKernelUpdater"
$downloadedWslKernelUpdaterInstallerPath = "$DscWorkDir\$wslKernelUpdater"

EnsureDownloadedUrl -Url $wslKernelUpdaterUrl -DownloadedPath $downloadedWslKernelUpdaterInstallerPath
$wslKernelUpdaterProductName = $msiTools::GetProductName($downloadedWslKernelUpdaterInstallerPath)
$wslKernelUpdaterProductGuid = $msiTools::GetProductCode($downloadedWslKernelUpdaterInstallerPath)

Configuration Wsl2 
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc  # needed for PendingReboot
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node "localhost" 
    {
        xWindowsOptionalFeatureSet WslFeatureSet
        {
            Name = (
                "Microsoft-Windows-Subsystem-Linux",
                "VirtualMachinePlatform"
            )
            NoWindowsUpdateCheck = $true
            Ensure               = "Present"
        }

        PendingReboot WinFeatureReboot
        {
            Name      = "BeforeWsl2KernelUpdater"
            DependsOn = "[xWindowsOptionalFeatureSet]WslFeatureSet"
        }

        Package WslKernelUpdater
        {
            DependsOn = "[PendingReboot]WinFeatureReboot"

            Name      = $wslKernelUpdaterProductName
            Path      = $downloadedWslKernelUpdaterInstallerPath
            ProductId = $wslKernelUpdaterProductGuid
            Ensure    = "Present"
        }

        Script SetWslDefaultVersion 
        {
            DependsOn = "[Package]WslKernelUpdater"
            Credential = $UserCredentialAtComputerDomain

            GetScript = {
                # Do nothing
            }
            TestScript = {
                $false  # it is cheap, do it always
            }
            SetScript = {
                wsl --set-default-version 2
                if ($LASTEXITCODE -ne 0) {
                    throw "Exited with $LASTEXITCODE"
                }
            }
        }
    }
}
ApplyDscConfiguration "Wsl2"
$rebootPending = (Get-DscLocalConfigurationManager).RebootPending
if ($rebootPending) {
    Write-Host "Reboot is pending."
    throw "Reboot is pending"
}

$wslDistroName = Split-Path -Path $userConfig.Wsl.Distro -Leaf
$wslDistroBundleDir = "$DscWorkDir\$wslDistroName"
EnsureExtractedUrl `
    -Url $userConfig.Wsl.Distro `
    -DownloadedPath "$DscWorkDir\$wslDistroName.appxbundle.zip" `
    -ExtractedDir $wslDistroBundleDir

$wslDistroAppx = Get-ChildItem -Path $wslDistroBundleDir -Filter "*_x64.appx" | Select-Object -Last 1
$wslDistroAppxPath = $wslDistroAppx.FullName
$wslDistroZipPath = "$DscWorkDir\$($wslDistroAppx.Name).zip"
$wslDistroDir = "$userBinDir\$($wslDistroAppx.Name)"
Configuration "ExtractWslDistro"
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        File WslDistroZip
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain

            Type            = "File"
            SourcePath      = $wslDistroAppxPath
            DestinationPath = $wslDistroZipPath
            Ensure          = "Present"
            Checksum        = "SHA-1"
        }

        Archive WslDistroUnzipped
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            DependsOn = "[File]WslDistroZip"

            Ensure      = "Present"
            Path        = $wslDistroZipPath
            Destination = $wslDistroDir
        }
    }
}
ApplyDscConfiguration "ExtractWslDistro"


$wslDistroAppxManifestXmlDoc = [xml](Get-Content -Path "$wslDistroDir\AppxManifest.xml")
$nsMgr = New-Object System.Xml.XmlNamespaceManager($wslDistroAppxManifestXmlDoc.NameTable)
$nsMgr.AddNamespace("ns", "http://schemas.microsoft.com/appx/manifest/foundation/windows10")
$wslDistroAppxName = $wslDistroAppxManifestXmlDoc.SelectSingleNode("//ns:Identity", $nsMgr).Name
Write-Host "Parsed wsl distro appx identity name: $wslDistroAppxName"
$wslDistroShortName = $wslDistroAppxName -split '\.' | Select-Object -Last 1

$wslCredential = ProvideCredential -Purpose "wsl_password_$wslDistroShortName" -Message "Specify password for wsl distro" -User $userConfig.Wsl.UserName
$wslDistroExe = "$wslDistroDir\$wslDistroShortName"
$outputFile = "$DscWorkDir\wsl_install.txt"
Write-Output "-----------------" | Out-File $outputFile -Append

# https://github.com/microsoft/WSL/issues/3369#issuecomment-803515113
Configuration "InstallWslDistro"
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DSCR_AppxPackage

    Node "localhost"
    {
        cAppxPackage WslDistroAppxPackageInstall
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain

            Name        = $wslDistroAppxName
            PackagePath = $wslDistroAppxPath
        }

        Script InstallWslDistro 
        {
            DependsOn = "[cAppxPackage]WslDistroAppxPackageInstall"
            Credential = $UserCredentialAtComputerDomain

            GetScript = {
                # do nothing
            }
            TestScript = {
                $output = (wsl -l) -replace "\x00",""
                $noInstalledDistributions = $output.Contains("Windows Subsystem for Linux has no installed distributions.")
                if ($noInstalledDistributions) {
                    return $false
                }
                $distro = "$using:wslDistroShortName"
                foreach ($line in $output -split '\r?\n') {
                    if ($line.StartsWith($distro)) {
                        return $true
                    }
                }
                return $false
            }
            SetScript = {
                $distro = $using:wslDistroExe
                # https://github.com/microsoft/WSL/issues/3369
                $wslCredential = $using:wslCredential
                $userName = $wslCredential.GetNetworkCredential().UserName
                $password = $wslCredential.GetNetworkCredential().Password

                & $distro install --root | Out-File $using:outputFile -Append
                if ($LASTEXITCODE -ne 0) {
                    throw "Exited with $LASTEXITCODE"
                }

                # TODO detect if not Ubuntu and skip followings

                # create user account
                & $distro run useradd -m "$username" | Out-File $using:outputFile -Append
                # wrapped in sh -c to get the pipe to work:
                & $distro run sh -c "echo "${username}:${password}" | chpasswd" | Out-File $using:outputFile -Append
                & $distro run chsh -s /bin/bash "$username" | Out-File $using:outputFile -Append
                & $distro run usermod -aG adm,cdrom,sudo,dip,plugdev "$username" | Out-File $using:outputFile -Append

                & $distro config --default-user "$username" | Out-File $using:outputFile -Append

                # initial system update
                $env:DEBIAN_FRONTEND = "noninteractive"
                $env:WSLENV += ":DEBIAN_FRONTEND"
                & $distro config --default-user "root" | Out-File $using:outputFile -Append
                & $distro run sh -c 'apt-get update && apt-get full-upgrade -y && apt-get autoremove -y && apt-get autoclean' | Out-File $using:outputFile -Append
                & $distro config --default-user "$username" | Out-File $using:outputFile -Append
                
                # https://github.com/microsoft/WSL/issues/7749
                #Restart-Service -Name vmcompute
                #gpupdate /force
            }
        }
    }
}
ApplyDscConfiguration "InstallWslDistro"
Get-Content $outputFile | Write-Verbose

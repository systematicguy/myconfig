. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\MsiTools.ps1
. $RepoRoot\helpers\Downloader.ps1
. $RepoRoot\helpers\Ini.ps1

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

            # You might encounter the following error: The return code 1603 was not expected. Configuration is likely not correct
            # This is most probably the case if you have already installed the WSL2 kernel update manually.
            # In this case you can ignore this error.
            # https://learn.microsoft.com/en-us/troubleshoot/windows-server/application-management/msi-installation-error-1603
        }

        Script SetWslDefaultVersion 
        {
            DependsOn = "[Package]WslKernelUpdater"
            Credential = $UserCredential

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

EnsureIniConfig -Path "$UserDir\.wslconfig" -IniConfig $UserConfig.Wsl[".wslconfig"]

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
            PsDscRunAsCredential = $UserCredential

            Type            = "File"
            SourcePath      = $wslDistroAppxPath
            DestinationPath = $wslDistroZipPath
            Ensure          = "Present"
            Checksum        = "SHA-1"
        }

        Archive WslDistroUnzipped
        {
            PsDscRunAsCredential = $UserCredential
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
Write-Host "Parsed wsl distro short name: $wslDistroShortName"

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
            PsDscRunAsCredential = $UserCredential

            Name        = $wslDistroAppxName
            PackagePath = $wslDistroAppxPath
        }

        Script InstallWslDistro 
        {
            DependsOn = "[cAppxPackage]WslDistroAppxPackageInstall"
            Credential = $UserCredential

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
                $distroName = $using:wslDistroShortName
                # https://github.com/microsoft/WSL/issues/3369
                $wslCredential = $using:wslCredential
                $userName = $wslCredential.GetNetworkCredential().UserName
                $password = $wslCredential.GetNetworkCredential().Password
                

                & $distro install --root | Out-File $using:outputFile -Append
                if ($LASTEXITCODE -ne 0) {
                    throw "Exited with $LASTEXITCODE"
                }

                # TODO detect if not Ubuntu and skip user creation and initial update

                # =============================================================================================================
                # create user account
                & $distro run useradd -m "$userName" | Out-File $using:outputFile -Append
                
                # following wizardry is required to get the pipe to work druing & $distro run:
                $commandString = "echo ""${userName}:${password}"" | chpasswd"
                $commandBytes = [System.Text.Encoding]::UTF8.GetBytes($commandString)
                $base64Command = [System.Convert]::ToBase64String($commandBytes)
                & $distro run "echo $base64Command | base64 --decode | sh" | Out-File $using:outputFile -Append

                & $distro run chsh -s /bin/bash "$userName" | Out-File $using:outputFile -Append
                & $distro run usermod -aG adm,cdrom,sudo,dip,plugdev "$userName" | Out-File $using:outputFile -Append
                & $distro config --default-user "$userName" | Out-File $using:outputFile -Append

                # =============================================================================================================
                # initial system update of the distro
                Write-Output "### Performing initial system update ..." | Out-File $using:outputFile -Append
                $env:DEBIAN_FRONTEND = "noninteractive"
                $env:WSLENV += ":DEBIAN_FRONTEND"
                Write-Output "### apt-get update ..." | Out-File $using:outputFile -Append
                wsl -u root -d $distroName sh -c 'apt-get update -qy' | ForEach-Object { $_ -replace "\x00", ""} | Out-File $using:outputFile -Append
                
                Write-Output "### apt-get upgrade ..." | Out-File $using:outputFile -Append
                wsl -u root -d $distroName sh -c 'apt-get full-upgrade -qy' | ForEach-Object { $_ -replace "\x00", ""} | Out-File $using:outputFile -Append
                
                Write-Output "### apt-get autoremove ..." | Out-File $using:outputFile -Append
                wsl -u root -d $distroName sh -c 'apt-get autoremove -qy' | ForEach-Object { $_ -replace "\x00", ""} | Out-File $using:outputFile -Append
                
                Write-Output "### apt-get autoclean ..." | Out-File $using:outputFile -Append
                wsl -u root -d $distroName sh -c 'apt-get autoclean -qy' | ForEach-Object { $_ -replace "\x00", ""} | Out-File $using:outputFile -Append
                
                # =============================================================================================================
                # /etc/wsl.conf inside the distro

                # TODO make configurable
                # use git to manage the ini-formatted /etc/wsl.conf
                wsl -u root -d $distroName sh -c 'git config --file=/etc/wsl.conf interop.enabled "false"'
                wsl -u root -d $distroName sh -c 'git config --file=/etc/wsl.conf interop.appendWindowsPath "false"'
                wsl -u root -d $distroName sh -c 'git config --file=/etc/wsl.conf automount.options "metadata,umask=22,fmask=111"'

                wsl --shutdown $distroName
                
                # as seen on https://learn.microsoft.com/en-us/windows/wsl/wsl-config#the-8-second-rule
                Start-Sleep -Seconds 8
                
                # https://github.com/microsoft/WSL/issues/7749
                #Restart-Service -Name vmcompute
                #gpupdate /force
            }
        }
    }
}
ApplyDscConfiguration "InstallWslDistro"
Get-Content $outputFile | Write-Verbose

# TODO $RepoRoot\scripts\excludeWSLfromDefender\excludeWSL.ps1
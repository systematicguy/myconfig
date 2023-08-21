. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\MsiTools.ps1
. $RepoRoot\helpers\Downloader.ps1
. $RepoRoot\helpers\Ini.ps1

. $RepoToolsDir\PsTools.ps1

$outputFile = "$DscWorkDir\wsl_install.txt"
Write-Output "-----------------" | Out-File $outputFile -Append

# https://learn.microsoft.com/en-us/windows/wsl/install-manual
# https://github.com/microsoft/WSL/issues/3369
# https://learn.microsoft.com/en-us/windows/wsl/install-on-server

$wslKernelUpdater = "wsl_update_x64.msi"
$wslKernelUpdaterUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/$wslKernelUpdater"
$downloadedWslKernelUpdaterInstallerPath = "$DscWorkDir\$wslKernelUpdater"

EnsureDownloadedUrl -Url $wslKernelUpdaterUrl -DownloadedPath $downloadedWslKernelUpdaterInstallerPath
$wslKernelUpdaterProductName = $msiTools::GetProductName($downloadedWslKernelUpdaterInstallerPath)
$wslKernelUpdaterProductGuid = $msiTools::GetProductCode($downloadedWslKernelUpdaterInstallerPath)

Configuration WslFeature
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
            Name      = "BeforeWslKernelUpdater"
            DependsOn = "[xWindowsOptionalFeatureSet]WslFeatureSet"

            SkipPendingFileRename = $true
        }
    }
}
ApplyDscConfiguration "WslFeature"
$rebootPending = (Get-DscLocalConfigurationManager).RebootPending
if ($rebootPending) {
    Write-Host "Reboot is pending."
    throw "Reboot is pending"
}

Configuration WslKernelUpdater
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

    Node "localhost" 
    {
        Package WslKernelUpdater
        {
            Name      = $wslKernelUpdaterProductName
            Path      = $downloadedWslKernelUpdaterInstallerPath
            ProductId = $wslKernelUpdaterProductGuid
            Ensure    = "Present"
            ReturnCode = @(
                0, 
                1603  # a newer version is already installed
            )

            # You might encounter the following error: The return code 1603 was not expected. Configuration is likely not correct
            # This is most probably the case if you have already installed the WSL2 kernel update manually.
            # In this case you can ignore this error.
            # https://learn.microsoft.com/en-us/troubleshoot/windows-server/application-management/msi-installation-error-1603
        }
    }
}
ApplyDscConfiguration "WslKernelUpdater" -IgnoreError # TODO find out how to make this nicer

Configuration WslVersion2
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

    Node "localhost" 
    {
        Script SetWslDefaultVersion 
        {
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
ApplyDscConfiguration "WslVersion2"

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

# ================================================================================================
# detect if wsl distro install is needed
$wslOutput = (wsl.exe -l) -replace "\x00",""
$noInstalledDistributions = $wslOutput.Contains("Windows Subsystem for Linux has no installed distributions.")
$wslDistroInstallNeeded = $false
if ($noInstalledDistributions) {
    Write-Host "No installed wsl distros detected."
    $wslDistroInstallNeeded = $true
} else {
    foreach ($line in $wslOutput -split '\r?\n') {
        if ($line.StartsWith($wslDistroShortName)) {
            Write-Host "[$wslDistroShortName] detected in line: [$line]"
            $wslDistroInstallNeeded = $false
            break
        }
    }
}
if ($wslDistroInstallNeeded) {
    Write-Host "wsl distro install is needed."

    $wslCredential = ProvideCredential -Purpose "wsl_password_$wslDistroShortName" -Message "Specify password for wsl distro" -User $userConfig.Wsl.UserName
    $wslDistroExe = "$wslDistroDir\$wslDistroShortName"

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
                    $false
                }
                SetScript = {
                    $distro = $using:wslDistroExe
                    $distroName = $using:wslDistroShortName
                    # https://github.com/microsoft/WSL/issues/3369
                    $wslCredential = $using:wslCredential
                    $userName = $wslCredential.GetNetworkCredential().UserName
                    $password = $wslCredential.GetNetworkCredential().Password
                    $RepoRoot = $using:RepoRoot

                    . $RepoRoot\helpers\ExecuteWithTimeout.ps1

                    Write-Output "### Installing [$distroName] using [$distro] ..." | Out-File $using:outputFile -Append
                    & $distro install --root | Out-File $using:outputFile -Append
                    if ($LASTEXITCODE -ne 0) {
                        throw "Exited with $LASTEXITCODE"
                    }

                    # TODO detect if not Ubuntu and skip user creation and initial update

                    # =============================================================================================================
                    # create user account
                    Write-Output "### Setting up [${userName}] user account and password ..." | Out-File $using:outputFile -Append
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

                    Write-Output "### Configuring /etc/wsl.conf ..." | Out-File $using:outputFile -Append
                    $wslConf = $using:UserConfig.Wsl["/etc/wsl.conf"]
                    foreach ($sectionKey in $wslConf.Keys) {
                        foreach ($key in $wslConf[$sectionKey].Keys) {
                            $value = $wslConf[$sectionKey][$key]
                            $iniCommand = "git config --file=/etc/wsl.conf $sectionKey.$key `"$value`""
                            Write-Output "### will perform: $iniCommand" | Out-File $using:outputFile -Append
                            wsl -u root -d $distroName sh -c $iniCommand
                        }
                    }
                    Write-Output "### cat /etc/wsl.conf ..."
                    wsl -u root -d $distroName sh -c 'cat /etc/wsl.conf' | Out-File $using:outputFile -Append

                    Write-Output "### Shutting down distro to take effect ..." | Out-File $using:outputFile -Append
                    ExecuteWithTimeout `
                        -CommandScriptBlock { wsl --shutdown $using:distroName } `
                        -TimeoutSeconds 10 `
                        -OnTimeoutScriptBlock { & "$using:RepoRoot\scripts\killWsl.ps1" } `
                        | Out-File $using:outputFile -Append
                    
                    # as seen on https://learn.microsoft.com/en-us/windows/wsl/wsl-config#the-8-second-rule
                    Write-Output "### Waiting 8 seconds ..." | Out-File $using:outputFile -Append
                    Start-Sleep -Seconds 8

                    # =============================================================================================================
                    # ansible enablement - a mvp-bootstrap that will do the rest of the setup from inside the distro
                    #  This compromise is the least intrusive way to get ansible installed and configured
                    # TODO apply https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu
                    #  and manage python3, pip, pipx from ansible
                    
                    Write-Output "### Bootstrapping ansible ..." | Out-File $using:outputFile -Append
                    wsl -u root -d $distroName sh -c 'apt-get install -y python3-pip' | Out-File $using:outputFile -Append
                    
                    # python3-venv is needed for pipx as ensurepip is not enabled for the system python on Ubuntu:
                    wsl -u root -d $distroName sh -c 'apt-get install -y python3-venv' | Out-File $using:outputFile -Append
                    wsl -d $distroName sh -c 'python3 -m pip install --user --progress-bar off pipx' | Out-File $using:outputFile -Append
                    wsl -d $distroName sh -c 'python3 -m pipx ensurepath' | Out-File $using:outputFile -Append
                    
                    wsl -d $distroName sh -lc 'pipx install --include-deps ansible' | Out-File $using:outputFile -Append
                    wsl -d $distroName sh -lc 'ansible --version' | Out-File $using:outputFile -Append
                    
                    # https://github.com/microsoft/WSL/issues/7749
                    #Restart-Service -Name vmcompute
                    #gpupdate /force
                }
            }
        }
    }
    ApplyDscConfiguration "InstallWslDistro"
    Get-Content $outputFile | Write-Verbose
}

Write-Output "### Excluding WSL from Windows Defender ..." | Out-File $outputFile -Append
& "$RepoRoot\scripts\excludeWSLfromDefender\excludeWSLfromDefender.ps1" | Out-File $outputFile -Append
. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoRoot\windows\MsiTools.ps1

# https://learn.microsoft.com/en-us/windows/wsl/install-manual
# https://github.com/microsoft/WSL/issues/3369
# https://learn.microsoft.com/en-us/windows/wsl/install-on-server

$wslKernelUpdater = "wsl_update_x64.msi"
$wslKernelUpdaterUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/$wslKernelUpdater"
$downloadedWslKernelUpdaterInstallerPath = "$DscWorkDir\$wslKernelUpdater"

if (! (Test-Path $downloadedWslKernelUpdaterInstallerPath)) {
    Configuration GetWslKernelUpdaterMsi
    {
        Import-DscResource -ModuleName xPSDesiredStateConfiguration

        Node "localhost" 
        {
            xRemoteFile DownloadWslKernelUpdater
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                DestinationPath      = $downloadedWslKernelUpdaterInstallerPath
                Uri                  = $wslKernelUpdaterUrl
            }
        }
    }
    ApplyDscConfiguration "GetWslKernelUpdaterMsi"
}

# immediately apply config so we can get GUID
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
$downloadedWslDistroPath = "$DscWorkDir\$wslDistroName.appx"
if (! (Test-Path $downloadedWslDistroPath)) {
    Configuration DownloadWslDistro
    {
        Import-DscResource -ModuleName xPSDesiredStateConfiguration

        Node "localhost" 
        {
            xRemoteFile DownloadWslDistro
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                DestinationPath      = $downloadedWslDistroPath
                Uri                  = $userConfig.Wsl.Distro
            }
        }
    }
    ApplyDscConfiguration "DownloadWslDistro"
}

$wslDistroZipPath = "$DscWorkDir\$wslDistroName.zip"
$wslDistroDir = "$UserBinDir\$wslDistroName"
Configuration "ExtractWslDistro"
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DSCR_AppxPackage

    Node "localhost"
    {
        File WslDistroZip
        {
            Type            = "File"
            SourcePath      = $downloadedWslDistroPath
            DestinationPath = $wslDistroZipPath
            Ensure          = "Present"
            Checksum        = "SHA-1"
        }

        Archive WslDistroUnzipped
        {
            DependsOn = "[File]WslDistroZip"

            Ensure      = "Present"
            Path        = $downloadedWslDistroPath
            Destination = $wslDistroDir
        }
    }
}
ApplyDscConfiguration "ExtractWslDistro"

$wslDistroAppx = Get-ChildItem -Path $wslDistroDir -Filter "*_x64.appx" | Select-Object -Last 1
$wslDistroAppxPath = $wslDistroAppx.FullName
$wslDistroAppxManifestXmlDoc = [xml](Get-Content -Path "$wslDistroDir\AppxMetadata\AppxBundleManifest.xml")
$ns = New-Object System.Xml.XmlNamespaceManager($wslDistroAppxManifestXmlDoc.NameTable)
$ns.AddNamespace("ns", "http://schemas.microsoft.com/appx/2013/bundle")
$wslDistroAppxName = $wslDistroAppxManifestXmlDoc.SelectSingleNode("//ns:Identity", $ns).Name
Write-Host "Parsed wsl distro appx identity name: $wslDistroAppxName"

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
    }
}
ApplyDscConfiguration "InstallWslDistro"

. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\MsiTools.ps1
. $RepoRoot\helpers\Downloader.ps1
. $RepoRoot\helpers\PendingReboot.ps1

$duplicatiInstaller = "duplicati-2.1.0.2_beta_2024-11-29-x64.msi"
$duplicatiInstallerUrl = "https://updates.duplicati.com/beta/$duplicatiInstaller"
$downloadedDuplicatiInstallerPath = "$DscWorkDir\$duplicatiInstaller"

EnsureDownloadedUrl -Url $duplicatiInstallerUrl -DownloadedPath $downloadedDuplicatiInstallerPath
$duplicatiInstallerProductName = $msiTools::GetProductName($downloadedDuplicatiInstallerPath)
$duplicatiInstallerProductGuid = $msiTools::GetProductCode($downloadedDuplicatiInstallerPath)

Configuration Duplicati
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

    Node "localhost" 
    {
        Package Duplicati
        {
            Name      = $duplicatiInstallerProductName
            Path      = $downloadedDuplicatiInstallerPath
            ProductId = $duplicatiInstallerProductGuid
            Ensure    = "Present"
            ReturnCode = @(0)
        }
    }
}
ApplyDscConfiguration "Duplicati"

EnsureNoPendingReboot

LogTodo -Message "Restart your machine to autostart Duplicati and import your backup settings."
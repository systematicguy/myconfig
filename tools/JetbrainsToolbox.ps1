. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

. $RepoToolsDir\Chocolatey.ps1

Configuration JetbrainsToolbox
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco

    Node "localhost"
    {
        cChocoPackageInstaller JetbrainsToolbox
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain

            Name = "jetbrainstoolbox"
        }
    }
}

ApplyDscConfiguration "JetbrainsToolbox"
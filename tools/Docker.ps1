. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoToolsDir\Chocolatey.ps1
. $RepoRoot\helpers\UserCredential.ps1

Configuration DockerDesktop
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco
    
    Node "localhost"
    {
        cChocoPackageInstaller DockerDesktop
        {
            PsDscRunAsCredential = $UserCredential

            Name = "docker-desktop"
        }
    }
}

ApplyDscConfiguration "DockerDesktop"

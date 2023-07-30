. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1

. $RepoToolsDir\Chocolatey.ps1

Configuration PyCharmProfessional
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco

    Node "localhost"
    {
        cChocoPackageInstaller PyCharmProfessional
        {
            PsDscRunAsCredential = $UserCredential

            Name = "pycharm"
        }
    }
}

ApplyDscConfiguration "PyCharmProfessional"

LogTodo -Message "PyCharm: You may want to turn log in to your JetBrains account and turn on settings sync"
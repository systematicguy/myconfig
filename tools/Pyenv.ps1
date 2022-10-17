. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoToolsDir\Chocolatey.ps1

$UserLocalAppData = $env:LOCALAPPDATA

Configuration Pyenv
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Name cChocoPackageInstaller -ModuleName cChoco

    Node "localhost"
    {
        cChocoPackageInstaller GoogleChrome
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain  # need to set for proper PATH
            Name                 = "pyenv-win"
        }

        # removing App Execution aliases as seen on https://superuser.com/a/1746939
        Script RemoveAppAlias 
        {
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                $localAppData = $using:UserLocalAppData
                Remove-Item $localAppData\Microsoft\WindowsApps\python.exe -ErrorAction SilentlyContinue
                Remove-Item $localAppData\Microsoft\WindowsApps\python3.exe -ErrorAction SilentlyContinue
            }
            TestScript = {
                $false
            }
        }
    }
}

Pyenv -Output $DscMofDir\Pyenv -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\Pyenv -Wait -Force -Verbose

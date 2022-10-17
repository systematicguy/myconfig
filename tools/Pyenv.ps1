. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoToolsDir\Chocolatey.ps1

$UserLocalAppData = $env:LOCALAPPDATA

$globalPythonVersion = $UserConfig.Python.GlobalVersion

Configuration PyenvConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Name cChocoPackageInstaller -ModuleName cChoco

    Node "localhost"
    {
        cChocoPackageInstaller Pyenv
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

        Script InstallGlobalPythonVersion
        {
            DependsOn = "[cChocoPackageInstaller]Pyenv"
            Credential = $UserCredentialAtComputerDomain
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                pyenv install $using:globalPythonVersion
                pyenv global $using:globalPythonVersion
            }
            TestScript = {
                (pyenv versions | Select-String $using:globalPythonVersion) -ne $null
            }
        }
    }
}

PyenvConfig -Output $DscMofDir\PyenvConfig -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\PyenvConfig -Wait -Force -Verbose

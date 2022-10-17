. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoToolsDir\Pyenv.ps1
. $RepoToolsDir\PipConfig.ps1

Configuration PipxConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName FileContentDsc

    Node "localhost"
    {
        Script InstallPipx
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                $env:PIP_REQUIRE_VIRTUALENV = 0
                pip install --disable-pip-version-check pipx
                pipx ensurepath
                # TODO: eliminate red output
            }
            TestScript = {
                $false
            }
        }

        IniSettingsFile RequireVirtualenv
        {
            Path    = $PipUserConfigPath
            Section = "global"
            Key     = "require-virtualenv"
            Text    = "True"
        }
    }
}

PipxConfig -Output $DscMofDir\PipxConfig -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\PipxConfig -Wait -Force -Verbose

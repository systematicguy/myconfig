. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
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
            PsDscRunAsCredential = $UserCredential
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
                try {
                    $foundPipxVersionString = (pipx --version)
                } catch {
                    $foundPipxVersionString = $null
                }
                $foundPipxVersionString -ne $null  # emit $true if already installed
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

ApplyDscConfiguration "PipxConfig"
LogTodo -Message "To reload changed user PATH environment variable, you have to relogin"
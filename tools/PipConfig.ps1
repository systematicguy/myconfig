. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoToolsDir\Pyenv.ps1

# ensure user pip ini
#  note: pip config --user lately updates AppData/Roaming/pip/pip.ini, so we don't configure using pip command
#  we want the pip folder to be in the user home (just like .ssh, .aws, etc)
$PipUserConfigPath = "$UserDir\pip\pip.ini"
if (! (Test-Path $PipUserConfigPath)) {
    New-Item -Path $PipUserConfigPath -ItemType File -Force
}

if ($userConfig.Python.PipIndexUrl -ne "") {
    Configuration PipConfig
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DSCResource -ModuleName FileContentDsc

        Node "localhost"
        {
            IniSettingsFile GlobalIndexUrl
            {
                Path    = $PipUserConfigPath
                Section = "global"
                Key     = "index-url"
                Text    = $UserConfig.Python.PipIndexUrl
            }
        }
    }

    ApplyDscConfiguration "PipConfig"
}

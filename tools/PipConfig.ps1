. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\EnsureFile.ps1
. $RepoRoot\helpers\Ini.ps1
. $RepoToolsDir\Pyenv.ps1

# ensure user pip ini
#  note: pip config --user lately updates AppData/Roaming/pip/pip.ini, so we don't configure using pip command
#  we want the pip folder to be in the user home (just like .ssh, .aws, etc)
$PipUserConfigPath = "$UserDir\pip\pip.ini"
EnsureFile -Path $PipUserConfigPath

if ($userConfig.Python.PipIndexUrl -ne "") {
    EnsureIniConfig -Path $PipUserConfigPath -IniConfig @{
        "global" = @{
            "index-url" = $UserConfig.Python.PipIndexUrl
        }
    }
}

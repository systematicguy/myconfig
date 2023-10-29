. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1
. $RepoRoot\helpers\JetbrainsContextMenus.ps1

EnsureChocoPackage -Name "pycharm"
SetupJetbrainsContextMenus -ToolName "PyCharm"

LogTodo -Message "PyCharm: You may want to turn log in to your JetBrains account and turn on settings sync"


# TODO inspect c:\Users\david\AppData\Roaming\JetBrains\PyCharm2023.2\options\other.xml and sorrounding files
# configure:
#  poetry executable through pipx
#  default interpreter
#  trusted project folders
#  global default test runner pytest
#  Dark theme should be Darcula
#  cache files should be excluded from windows defender

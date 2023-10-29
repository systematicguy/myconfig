. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1
. $RepoRoot\helpers\JetbrainsContextMenus.ps1

EnsureChocoPackage -Name "webstorm"
SetupJetbrainsContextMenus -ToolName "WebStorm"

LogTodo -Message "Webstorm: You may want to turn log in to your JetBrains account and turn on settings sync"
. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1

EnsureChocoPackage -Name "webstorm"

LogTodo -Message "Webstorm: You may want to turn log in to your JetBrains account and turn on settings sync"
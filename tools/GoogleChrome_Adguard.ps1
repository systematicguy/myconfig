. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1

. $RepoToolsDir\GoogleChrome.ps1

EnsureChocoPackage -Name "adguard-chrome"

LogTodo -Message "Check if Adguard really got installed to Chrome"
. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1

EnsureChocoPackage -Name "grammarly-for-windows"

LogTodo -Message "Grammarly: You may want to log in to your grammarly account"
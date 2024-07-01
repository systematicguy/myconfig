. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1

#EnsureChocoPackage -Name "microsoft-teams"
EnsureChocoPackage -Name "microsoft-teams-new-bootstrapper"

# TODO disable autostart
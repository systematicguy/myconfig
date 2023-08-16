. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1

# this brings you pwsh a.k.a. powershell 7
EnsureChocoPackage -Name "powershell-core"

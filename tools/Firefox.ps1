. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\Chocolatey.ps1


# This package uses Chrome's administrative MSI installer and installs the 32-bit on 32-bit OSes and the 64-bit version on 64-bit OSes.
# If this package is installed on a 64-bit OS and the 32-bit version of Chrome is already installed, the package keeps installing/updating the 32-bit version of Chrome.
EnsureChocoPackage -Name "firefox"

# TODO make defaultable, see GoogleChrome.ps1 setdefaultbrowser choco package

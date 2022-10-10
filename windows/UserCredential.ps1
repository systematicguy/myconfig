. $PSScriptRoot\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { 
    Write-Output "Working with existing credential for $($UserCredentialAtComputerDomain.UserName) and $($UserCredentialAtAd.UserName)"
    return
} else { $AlreadySourced[$PSCommandPath] = $true }

# Important Note: Domain on which your computer is registered might not be same as the domain on which the logged-in user is registered.
#  The %USERDOMAIN% and the network computer domain can be different.

$DomainUser = whoami  # e.g. BIG\horvathda
$UserCredentialAtAd = Get-Credential -Message "Specify your credential" -User $DomainUser

$commonUserPassword = $UserCredentialAtAd.Password
$ComputerDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain  # e.g. big.ch
$UserCredentialAtComputerDomain = New-Object System.Management.Automation.PSCredential ("$UserName@$ComputerDomain", $commonUserPassword)

# useful resources for future reference
# http://woshub.com/convert-sid-to-username-and-vice-versa/
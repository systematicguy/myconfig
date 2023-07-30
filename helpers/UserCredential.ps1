# we don't do . $PSScriptRoot\..\windows\Environment.ps1 here for a reason: 
# . helpers\UserCredential.ps1 can help you ease debugging without the danger of rewriting stuff but still using
#  dangling .-sourced left-over stuff from Environment.ps1's AlreadySourced table.

$DomainUser = whoami  # e.g. BIG\horvathda
$parsedUserName = ($DomainUser -split "\\")[-1]

if ($AlreadySourcedUserCredential -ne $null) { 
    Write-Output "Working with existing credential for [$($UserCredentialAtComputerDomain.UserName)] and [$($UserCredentialAtAd.UserName)]"
    if ($parsedUserName -ne $UserName) {
        Write-Output "Warning: your UserName coming from your local_config\UserConfig.psd1 is [$UserName] while whoami is [$(whoami)]"
    }
    return 
} else { $AlreadySourcedUserCredential = $true }

# Important Note: Domain on which your computer is registered might not be same as the domain on which the logged-in user is registered.
#  The %USERDOMAIN% and the network computer domain can be different.

$UserCredentialAtAd = Get-Credential -Message "Specify your credential" -User $DomainUser

#$commonUserPassword = $UserCredentialAtAd.Password
#$ComputerDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain  # e.g. big.ch
#$UserCredentialAtComputerDomain = New-Object System.Management.Automation.PSCredential("$parsedUserName@$ComputerDomain", $commonUserPassword)

$UserCredentialAtComputerDomain = $UserCredentialAtAd

# useful resources for future reference
# http://woshub.com/convert-sid-to-username-and-vice-versa/
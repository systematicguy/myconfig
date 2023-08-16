# we don't do . $PSScriptRoot\..\windows\Environment.ps1 here for a reason: 
# . helpers\UserCredential.ps1 can help you ease debugging without the danger of rewriting stuff but still using
#  dangling .-sourced left-over stuff from Environment.ps1's AlreadySourced table.

$DomainUser = whoami  # e.g. BIG\horvathda for a domain-joined enterprise computer; e.g. DESKTOP-1\horvathda for a BYOD non-domain-joined computer
$parsedUserName = ($DomainUser -split "\\")[-1]

if ($null -ne $AlreadySourcedUserCredential) { 
    Write-Output "Working with previously queried credential for [$($UserCredential.UserName)]"
    if ($parsedUserName -ne $UserName) {
        Write-Output "Warning: your UserName coming from your local_config\UserConfig.psd1 is [$UserName] while whoami is [$(whoami)]"
    }
    return 
}

$ComputerDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain  # e.g. big.ch for a domain-joined enterprise computer; WORKGROUP for a BYOD non-domain-joined computer
if ($ComputerDomain -eq "WORKGROUP") {
    $queriedUserName = ""
    $queryMessage = "It seems you are using a non-domain joined machine. If you use a local user, please specify your username. If you use a Microsoft account, please specify your email address."
} else {
    $queriedUserName = $DomainUser
    $queryMessage = "Please specify your credential"
}

while ($true) {
    $UserCredential = Get-Credential -Message $queryMessage -UserName $queriedUserName
    try {
        Invoke-Command -Credential $UserCredential -ComputerName localhost -ScriptBlock {Write-Output "Testing your credentials"}
        break
    } catch {
        Write-Output "Your credentials are not working. Please try again."
        if (-not ($queryMessage.StartsWith("Your credentials are not working"))) {
            $queryMessage = "Your credentials are not working! Please try again. $queryMessage"
        }
    }
}

# Important Note: Domain on which your computer is registered might not be same as the domain on which the logged-in user is registered.
#  The %USERDOMAIN% and the network computer domain can be different.

# At first the following variable name was used to input the password and used at some places. 
# Later it was eliminated and only $UserCredentialAtComputerDomain was used.
#$UserCredentialAtAd = Get-Credential -Message "Specify your credential" -User $DomainUser

# For a while the following was used throughout configuration, however it was only working for domain-joined enterprise computers.
# When a BYOD non-domain-joined computer was used with a non-local user logged in as an ms-account, the following was failing.
# Especially (Get-CimInstance -ClassName Win32_ComputerSystem).Domain was returning the pc's name and the username@pcname was not a valid user.
#$commonUserPassword = $UserCredentialAtAd.Password
#$UserCredentialAtComputerDomain = New-Object System.Management.Automation.PSCredential("$parsedUserName@$ComputerDomain", $commonUserPassword)

# useful resources for future reference
# http://woshub.com/convert-sid-to-username-and-vice-versa/

$AlreadySourcedUserCredential = $true
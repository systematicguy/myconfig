# to help yourself debugging:
# . windows\CredentialProvider.ps1
if ($CachedCredentials -eq $null) { 
    $CachedCredentials = @{} 
}

function ProvideCredential {
    param (
        [string]$Purpose,
        [string]$Message,
        [string]$username = "n. a."
    )

    if ($CachedCredentials.ContainsKey($Purpose)) {
        Write-Host "Working with existing credential for purpose [$Purpose]: username: [$($CachedCredentials[$Purpose].UserName)]"
        return $CachedCredentials[$Purpose]
    }
    do {
        $credential = Get-Credential -Message $Message -UserName $username
        $confirmedCredential = Get-Credential -Message "Confirm password" -UserName $credential.GetNetworkCredential().UserName
        if (-not ($message.StartsWith("Passwords mismatch."))) {
            $message = "Passwords mismatch. $message"
        }
    }
    while ($credential.GetNetworkCredential().Password -ne $confirmedCredential.GetNetworkCredential().Password)
    
    $CachedCredentials[$Purpose] = $credential
    return $credential
}
# to help yourself debugging:
# . helpers\CredentialProvider.ps1
if ($null -eq $CachedCredentials) { 
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
        if ($null -eq $credential) {
            Write-Host "Cancelled the credential dialog";
            throw "Cancelled the credential dialog";
        }
        $confirmedCredential = Get-Credential -Message "Confirm password" -UserName $credential.GetNetworkCredential().UserName
        if ($null -eq $confirmedCredential) {
            Write-Host "Cancelled the credential dialog";
            throw "Cancelled the credential dialog";
        }
        if (-not ($message.StartsWith("Passwords mismatch."))) {
            $message = "Passwords mismatch. $message"
        }
    }
    while ($credential.GetNetworkCredential().Password -ne $confirmedCredential.GetNetworkCredential().Password)
    
    $CachedCredentials[$Purpose] = $credential
    return $credential
}
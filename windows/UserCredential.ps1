if ($UserCredential -eq $null) 
{
    Write-Output "Retrieving domain..."
    $domainDesc = (systeminfo | findstr /B /C:"Domain") | Out-String
    $UserCredential = Get-Credential -Message "Specify credential like user@domain. $domainDesc"
} 
else 
{
    Write-Output "Working with existing credentials for $($UserCredential.UserName)"
}

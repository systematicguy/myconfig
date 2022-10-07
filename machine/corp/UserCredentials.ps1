if ($UserCredentials -eq $null) 
{
    Write-Output "Retrieving domain..."
    $domainDesc = (systeminfo | findstr /B /C:"Domain") | Out-String
    $UserCredentials = Get-Credential -Message "Specify credentials like user@domain. $domainDesc"
} 
else 
{
    Write-Output "Working with existing credentials for $($UserCredentials.UserName)"
}

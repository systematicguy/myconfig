# this script was born during troubleshooting

. $PSScriptRoot\..\helpers\UserCredential.ps1

Invoke-Command -Credential $UserCredentialAtAd -ComputerName localhost `
    -ScriptBlock {Write-Output "Invoke-Command with UserCredentialAtAd: Your credential works"}
Invoke-Command -Credential $UserCredentialAtAd -ComputerName localhost `
    -ScriptBlock {Write-Output "Profile is $Profile"}

Invoke-Command -Credential $UserCredentialAtComputerDomain -ComputerName localhost `
    -ScriptBlock {Write-Output "Invoke-Command with UserCredentialAtComputerDomain: Your credential works"}
Invoke-Command -Credential $UserCredentialAtComputerDomain -ComputerName localhost `
    -ScriptBlock {Write-Output "Profile is $Profile"}

Start-Process PowerShell.exe -Credential $UserCredentialAtAd "-command whoami"  # works
# Start-Process PowerShell.exe -Credential $UserCredentialAtComputerDomain "-command whoami"  # will not work

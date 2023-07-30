# this script was born during troubleshooting

. $PSScriptRoot\..\helpers\UserCredential.ps1

Invoke-Command -Credential $UserCredential -ComputerName localhost `
    -ScriptBlock {Write-Output "Invoke-Command with UserCredential: Your credential works"}
Invoke-Command -Credential $UserCredential -ComputerName localhost `
    -ScriptBlock {Write-Output "Profile is $Profile"}  # This is empty due to not being executed with the computer's domain

# See UserCredential.ps1 for history of this snippet:
# Invoke-Command -Credential $UserCredentialAtComputerDomain -ComputerName localhost `
#     -ScriptBlock {Write-Output "Invoke-Command with UserCredentialAtComputerDomain: Your credential works"}
# Invoke-Command -Credential $UserCredentialAtComputerDomain -ComputerName localhost `
#     -ScriptBlock {Write-Output "Profile is $Profile"}  # $Profile worked here

Start-Process PowerShell.exe -Credential $UserCredential "-command whoami"  # works
# Start-Process PowerShell.exe -Credential $UserCredentialAtComputerDomain "-command whoami"  # will not work

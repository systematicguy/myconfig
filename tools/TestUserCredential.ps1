# this script was born during troubleshooting
Invoke-Command -Credential $UserCredentialAtComputerDomain -ScriptBlock {Write-Output "Invoke-Command with UserCredentialAtComputerDomain: Your credential works"} -ComputerName localhost
Invoke-Command -Credential $UserCredentialAtAd -ScriptBlock {Write-Output "Invoke-Command with UserCredentialAtAd: Your credential works"} -ComputerName localhost

Invoke-Command -Credential $UserCredentialAtComputerDomain -ScriptBlock {Write-Output "Profile is $Profile"} -ComputerName localhost

Start-Process PowerShell.exe -Credential $UserCredentialAtAd "-command whoami"  # works
# Start-Process PowerShell.exe -Credential $UserCredentialAtComputerDomain "-command whoami"  # will not work

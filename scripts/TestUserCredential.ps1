# this script was born during troubleshooting

. $PSScriptRoot\..\windows\Environment.ps1

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

Write-Output "Testing DSC Script with Credentials..."
Configuration TestUserCredential
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Script TestUserCredential
        {
            Credential = $UserCredential

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                whoami
                Write-Output "here goes nothing"
            }
            TestScript = {
                $false
            }
        }
    }
}
ApplyDscConfiguration "TestUserCredential"
. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1

Configuration PowershellConfig
{
    Import-DSCResource -ModuleName xPowerShellExecutionPolicy

    Node "localhost"
    {        
        xPowerShellExecutionPolicy RemoteSigned
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            ExecutionPolicy = "RemoteSigned"
        }
    }
}

ApplyDscConfiguration "PowershellConfig"

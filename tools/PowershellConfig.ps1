. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

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

PowershellConfig -Output $DscMofDir\PowershellConfig -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\PowershellConfig -Wait -Force -Verbose

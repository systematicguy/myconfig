. $PSScriptRoot\Environment
. $PSScriptRoot\VsCode.ps1

configuration BaseMachineConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco 

    Node "localhost"
    {
        cChocoPackageInstaller InstallGit
        {
            Name = "git"
        }
    }
}

BaseMachineConfig -Output $DscMofDir\BaseMachineConfig
Start-DscConfiguration -Path $DscMofDir\BaseMachineConfig -Wait -Force -Verbose
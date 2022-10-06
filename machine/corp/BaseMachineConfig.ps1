configuration BaseMachineConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco 

    Node "localhost"
    {
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\ProgramData\chocolatey"
        }

        cChocoPackageInstaller InstallVsCode
        {
            Name      = "vscode"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }
        # TODO: auto-theme switch

        cChocoPackageInstaller InstallGit
        {
            Name      = "git"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }
    }
}


# Compile the configuration file to a MOF format
BaseMachineConfig

Start-DscConfiguration -Path .\BaseMachineConfig -Wait -Force -Verbose
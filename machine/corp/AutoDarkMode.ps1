configuration AutoDarkMode
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco 

    Node "localhost"
    {
        cChocoPackageInstaller InstallAutoDarkMode
        {
            Name = "auto-dark-mode"
        }

        # the installer does not ensure config, config will be generated upon first start,
        # so it is safe to pre-copy the config.yaml
        
        File AutoDarkModeConfig
        {
            DependsOn = "[cChocoPackageInstaller]InstallAutoDarkMode"

            Type            = 'File'
            SourcePath      = "C:\Users\horvathda\myconfig\tools\windows\auto_dark_mode\config.yaml"
            DestinationPath = 'C:\Users\horvathda\AppData\Roaming\AutoDarkMode\config.yaml'
            Ensure          = "Present"
            Checksum        = "SHA-1"
        }
    }
}


# Compile the configuration file to a MOF format
AutoDarkMode

Start-DscConfiguration -Path .\AutoDarkMode -Wait -Force -Verbose
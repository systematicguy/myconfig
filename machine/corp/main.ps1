# need to run as administrator

# use powershell 5.1+, don't use powershell 7.2
# They have removed DSC from 7.2 https://learn.microsoft.com/en-us/powershell/scripting/dsc/overview?view=powershell-7.2
# The lowest installable version is 2.0.5 from the gallery.
# https://www.powershellgallery.com/packages?q=PSDesiredStateConfiguration
# Anyways, I tried with 7.2 as admin and it could not Import cChoco.
# With version 5 it worked.

Set-WinUILanguageOverride -Language en-US

configuration CorporateMachine
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName cChoco 

    Node "localhost"
    {
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\ProgramData\chocolatey"
        }

        cChocoPackageInstaller InstallGit
        {
            Name = "git"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallAutoDarkMode
        {
            Name = "auto-dark-mode"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }

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
CorporateMachine

# Run the configuration on localhost
Start-DscConfiguration -Path .\CorporateMachine -Wait -Force -Verbose
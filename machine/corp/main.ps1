# need to run as administrator

# use powershell 5.1+, don't use powershell 7.2
# They have removed DSC from 7.2 https://learn.microsoft.com/en-us/powershell/scripting/dsc/overview?view=powershell-7.2
# The lowest installable version is 2.0.5 from the gallery.
# https://www.powershellgallery.com/packages?q=PSDesiredStateConfiguration
# Anyways, I tried with 7.2 as admin and it could not Import cChoco.
# With version 5 it worked.

Set-WinUILanguageOverride -Language en-US

configuration FileDemo
{
    # Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName cChoco 
    # Import-DscResource -ModuleName cChoco -Name cChocoInstaller 
    # Import-DscResource -ModuleName cChoco -Name cChocoPackageInstaller

    Node "localhost"
    {
        cChocoInstaller installChoco
        {
            InstallDir = "c:\ProgramData\chocolatey"
        }

        cChocoPackageInstaller installGit
        {
            Name = "git"
            DependsOn = "[cChocoInstaller]installChoco"
        }

        File Demo 
        {
            Type            = 'Directory'
            DestinationPath = 'C:\Users\horvathda\fostalicska'
            Ensure          = "Present"
        }
    }
}

# Compile the configuration file to a MOF format
FileDemo

# Run the configuration on localhost
Start-DscConfiguration -Path .\FileDemo -Wait -Force -Verbose
# need to run as administrator

# use powershell 5.1+, don't use powershell 7.2
# They have removed DSC from 7.2 https://learn.microsoft.com/en-us/powershell/scripting/dsc/overview?view=powershell-7.2
# The lowest installable version is 2.0.5 from the gallery.
# https://www.powershellgallery.com/packages?q=PSDesiredStateConfiguration
# Anyways, I tried with 7.2 as admin and it could not Import cChoco.
# With version 5 it worked.

Set-WinUILanguageOverride -Language en-US

.\BaseMachineConfig.ps1
.\AutoDarkMode.ps1
.\TotalCommander.ps1

. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

Configuration Chocolatey
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco

    Node "localhost"
    {
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\ProgramData\chocolatey"
        }
    }
}

ApplyDscConfiguration "Chocolatey"
. $PSScriptRoot\Environment

configuration Chocolatey
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

Chocolatey -Output $DscMofDir\Chocolatey
Start-DscConfiguration -Path $DscMofDir\Chocolatey -Wait -Force -Verbose
. $PSScriptRoot\Environment.ps1

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
        # would we want to prepare for merging to existing config.yaml, the followings will be needed:
        #  choco install yq -y
        #  Install-Module -Name PSYamlQuery -Force
        
        File AutoDarkModeConfig
        {
            DependsOn = "[cChocoPackageInstaller]InstallAutoDarkMode"

            Type            = 'File'
            SourcePath      = "$RepoRoot\tools\windows\auto_dark_mode\config.yaml"
            DestinationPath = "$UserDir\AppData\Roaming\AutoDarkMode\config.yaml"
            Ensure          = "Present"
            Checksum        = "SHA-1"
        }
    }
}

AutoDarkMode -Output $DscMofDir\AutoDarkMode
Start-DscConfiguration -Path $DscMofDir\AutoDarkMode -Wait -Force -Verbose
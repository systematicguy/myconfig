. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1
. $RepoRoot\helpers\EnsureFile.ps1
. $RepoRoot\helpers\Yaml.ps1

EnsureChocoPackage -Name "auto-dark-mode"

$autoDarkModeSettingsPath = "$UserDir\AppData\Roaming\AutoDarkMode\config.yaml"
# The installer does not ensure config. The app would ensure a config file upon start if not present. 
# However, to be able to merge our config to it, we have to ensure it is present.
EnsureFile `
    -Path $autoDarkModeSettingsPath
    #-EncodingIfMissing ASCII

# The app ensures missing values are present, retaining valid present configuration.
# It is also safe to configure it even if it is running.
EnsureYamlConfig `
    -Path $autoDarkModeSettingsPath `
    -YamlConfigPath "$RepoRoot\config\auto_dark_mode\config.yaml"  # TODO make configurable

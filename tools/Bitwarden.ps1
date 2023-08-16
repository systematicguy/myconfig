. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1
. $RepoRoot\helpers\EnsureFile.ps1
. $RepoRoot\helpers\Json.ps1

EnsureChocoPackage -Name "bitwarden"

EnsureFile `
    -Path $dockerSettingsPath `
    -EncodingIfMissing ASCII `
    -ContentIfMissing "{}"

# TODO: untested:
# https://bitwarden.com/help/configure-clients/#desktop-apps
EnsureJsonConfig `
    -Path "$UserDir\AppData\Roaming\Bitwarden\data.json" `
    -JsonConfigPath "$RepoRoot\config\bitwarden\data.json"

LogTodo -Message "bitwarden: check if config is working & configure browser extension"
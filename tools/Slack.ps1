. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1
. $RepoRoot\helpers\Json.ps1

$slackSettingsPath = "$UserDir\AppData\Roaming\Slack\storage\root-state.json"

EnsureChocoPackage -Name "slack"

EnsureJsonConfig `
    -Path $slackSettingsPath `
    -JsonConfigObject $UserConfig.Slack['root-state.json']

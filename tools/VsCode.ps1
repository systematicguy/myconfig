. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Json.ps1
. $RepoRoot\helpers\Chocolatey.ps1

EnsureChocoPackage -Name "vscode"
# TODO: plugins

EnsureJsonConfig `
    -Path "$UserDir\AppData\Roaming\Code\User\settings.json" `
    -JsonConfigPath "$RepoRoot\config\vscode\settings.json" # TODO make configurable

$VsCodeExePath = "C:\Program Files\Microsoft VS Code\Code.exe"

LogTodo -Message "VSCode: You may want to turn on Settings Sync (sign in to Github)"

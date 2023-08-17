. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1
. $RepoRoot\helpers\Json.ps1
. $RepoRoot\helpers\Registry.ps1

EnsureChocoPackage -Name "microsoft-windows-terminal"

# https://learn.microsoft.com/en-us/windows/terminal/install#settings-json-file
# https://stackoverflow.com/questions/63101571/where-is-the-windows-terminal-settings-location
$windowsTerminalConfigPath = "$UserDir\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (-not (Test-Path -Path $windowsTerminalConfigPath)) {
    # This should be the case when using chocolatey, however once you had installed through the store, 
    # even if uninstalling and reinstalling with choco, settings will use the ugly location.
    $windowsTerminalConfigPath = "$UserDir\AppData\Local\Microsoft\WindowsTerminal\settings.json"
}

# no problem if the terminal is already running
EnsureJsonConfig `
    -Path $windowsTerminalConfigPath `
    -JsonConfigObject $UserConfig.WindowsTerminal["settings.json"]

# https://www.winhelponline.com/blog/set-default-terminal-windows-11/
EnsureRegistry -Purpose "DefaultTerminalApplication" -RegistryConfig @{
    "HKCU:\Console\%%Startup" = @{
        DelegationConsole  = "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
        DelegationTerminal = "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
    }
}

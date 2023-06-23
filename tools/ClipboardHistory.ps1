. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Registry.ps1

EnsureRegistry -Purpose "ClipboardHistory" -RegistryConfig @{
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Clipboard" = @{   
        EnableClipboardHistory = 0x00000001
        PastedFromClipboardUI  = 0x00000001
        ShellHotKeyUsed        = 0x00000001
    }
}

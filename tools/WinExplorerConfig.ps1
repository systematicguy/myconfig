. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Registry.ps1

EnsureRegistry -Purpose "WinExplorerConfig" -RegistryConfig @{
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" = @{
        MMTaskbarEnabled  = 0x00000001  # Show taskbar on multiple displays
        MMTaskbarMode     = 0x00000000  # Show taskbar buttons on all taskbars
        ShowCortanaButton = 0x00000000  # Hide Cortana button
        TaskbarAl         = 0x00000000  # Taskbar alignment: Left
        TaskbarMn         = 0x00000000  # Hide chat from Taskbar
    }
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh" = @{
        AllowNewsAndInterests = 0x00000000  # Disable News and Interests Widget
    }
}

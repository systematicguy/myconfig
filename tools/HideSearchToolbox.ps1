. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Registry.ps1

EnsureRegistry -Purpose "HideSearchToolbox" -RegistryConfig @{
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" = @{
        "SearchboxTaskbarMode" = 0x00000000  # 0 = Hidden; 1 = Show serch or Cortana icon; 2 = Show search box
    }
}

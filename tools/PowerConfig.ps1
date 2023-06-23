. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Registry.ps1

EnsureRegistry -Purpose "PowerConfig" -RegistryConfig @{
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" = @{
        HibernateEnabled = 0x00000001
    }
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" = @{
        ShowHibernateOption = 0x00000001
    }
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer" = @{
        ShowHibernateOption = 0x00000001
    }
}

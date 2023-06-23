. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Registry.ps1

EnsureRegistry -Purpose "LongPathsEnabled" -RegistryConfig @{
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem" = @{
        LongPathsEnabled = 0x00000001
    }
}

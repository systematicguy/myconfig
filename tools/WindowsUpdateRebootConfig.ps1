. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Registry.ps1

EnsureRegistry -Purpose "DisableAutomaticReboot" -RegistryConfig @{
    # https://superuser.com/questions/957267/how-to-disable-automatic-reboots-in-windows-10
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" = @{
        # AUOptions = 0x00000002  # Notify before downloading and installing any updates.
        AUOptions = 0x00000003  # Download the updates automatically and notify when they are ready to be installed
        # AUOptions = 0x00000004  # Automatically download updates and install them on the schedule (install time-window not configured!)

    }
}

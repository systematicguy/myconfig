. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

Configuration WinExplorerConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        # Outlook Calendar
        $explorerSettings = @{
            "MMTaskbarEnabled"    = 0x00000001  # Show taskbar on multiple displays
            "MMTaskbarMode"       = 0x00000000  # Show taskbar buttons on all taskbars
            "ShowCortanaButton"   = 0x00000000  # Hide Cortana button

        }
        foreach ($valueName in $explorerSettings.Keys)
        {
            Registry "WinExplorer_$valueName"
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
                ValueName = $valueName
                ValueType = "Dword"
                ValueData = $explorerSettings[$valueName]
            }
        }
    }
}

ApplyDscConfiguration "WinExplorerConfig"


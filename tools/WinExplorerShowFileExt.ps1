. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

Configuration WinExplorerShowFileExt
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Registry "WinExplorerShowFileExt"  
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            
            Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            ValueName = "HideFileExt"
            ValueType = "Dword"
            ValueData = 0x00000000  # 1 = Show; 2 = Hide
        }
    }
}

ApplyDscConfiguration "WinExplorerShowFileExt"


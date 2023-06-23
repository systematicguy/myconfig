. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1

Configuration WinExplorerShowHiddenFiles
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Registry "ShowHidden"  
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            
            Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            ValueName = "Hidden"
            ValueType = "Dword"
            ValueData = 0x00000001
        }
    }
}

ApplyDscConfiguration "WinExplorerShowHiddenFiles"

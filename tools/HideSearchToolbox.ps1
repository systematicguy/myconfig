. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1

Configuration HideSearchToolbox
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Registry "HideSearchToolbox"  
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            
            Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
            ValueName = "SearchboxTaskbarMode"
            ValueType = "Dword"
            ValueData = 0x00000000  # 0 = Hidden; 1 = Show serch or Cortana icon; 2 = Show search box
        }
    }
}

ApplyDscConfiguration "HideSearchToolbox"

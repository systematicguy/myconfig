. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1

#https://learn.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=registry

Configuration LongPathsEnabled
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Registry "LongPathsEnabled"  
        {
            #PsDscRunAsCredential = $UserCredentialAtComputerDomain
            
            Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem"
            ValueName = "LongPathsEnabled"
            ValueType = "Dword"
            ValueData = 0x00000001
        }
    }
}

ApplyDscConfiguration "LongPathsEnabled"


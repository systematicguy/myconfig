. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

Configuration ClipboardHistory
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        # clipboard history: use Win+V to paste from history
        foreach ($valueName in @("EnableClipboardHistory", "PastedFromClipboardUI", "ShellHotKeyUsed"))
        {
            Registry "Clipboard_$valueName"  
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Clipboard"
                ValueName = $valueName
                ValueType = "Dword"
                ValueData = 0x00000001
            }
        }
    }
}

ClipboardHistory -Output $DscMofDir\ClipboardHistory -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\ClipboardHistory -Wait -Force -Verbose

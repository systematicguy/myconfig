. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1

Configuration LanguageConfig
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

        $languageBar = @{
            ExtraIconsOnMinimized = 1
            Label                 = 1
            ShowStatus            = 4
            Transparency          = 255
        }
        # Language Bar
        foreach ($valueName in $languageBar.Keys)
        {
            Registry "Clipboard_$valueName"  
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\CTF\LangBar"
                ValueName = $valueName
                ValueType = "Dword"
                ValueData = $languageBar[$valueName]
            }
        }

        # Language Order
        $languageRegistry = @{
            "DE-ch" = @{
                SortOrderLanguageName     = "00000000"
                KeyboardLayoutPreloadName = "1"
                Value = "00000807"
            }
            "EN-us" = @{
                SortOrderLanguageName     = "00000001"
                KeyboardLayoutPreloadName = "2"
                Value = "00000409"
            }
            "HU-hu" = @{
                SortOrderLanguageName     = "00000002"
                KeyboardLayoutPreloadName = "3"
                Value = "0000040e"
            }
        }
        foreach ($language in $UserConfig.KeyboardLanguagesInOrder)
        {
            Registry "SortOrderLanguage_$language"  
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\CTF\SortOrder\Language"
                ValueName = $languageRegistry[$language].SortOrderLanguageName
                ValueType = "String"
                ValueData = $languageRegistry[$language].Value
            }

            Registry "KeyboardLayoutPreload_$language"  
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "HKEY_CURRENT_USER\Keyboard Layout\Preload"
                ValueName = $languageRegistry[$language].KeyboardLayoutPreloadName
                ValueType = "String"
                ValueData = $languageRegistry[$language].Value
            }
        }
    }
}

ApplyDscConfiguration "LanguageConfig"
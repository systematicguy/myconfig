. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Registry.ps1

$languageOrderConfig = @{
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\CTF\LangBar" = @{
        ExtraIconsOnMinimized = 1
        Label                 = 1
        ShowStatus            = 4
        Transparency          = 255
    }
}

$languageTemplates = @{
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
    $languageTemplate = $languageTemplates[$language]
    $languageOrderConfig["HKEY_CURRENT_USER\SOFTWARE\Microsoft\CTF\SortOrder\Language"] += @{
        $languageTemplate.SortOrderLanguageName = $languageTemplate.Value
    }
    $languageOrderConfig["HKEY_CURRENT_USER\Keyboard Layout\Preload"] += @{
        $languageTemplate.KeyboardLayoutPreloadName = $languageTemplate.Value
    }
}
$languageOrderConfig | ConvertTo-Json -Depth 4

EnsureRegistry -Purpose "LanguageOrder" -RegistryConfig $languageOrderConfig

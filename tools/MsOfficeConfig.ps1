. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Registry.ps1

EnsureRegistry -Purpose "MsOfficeConfig" -RegistryConfig @{
    # https://www.kapilarya.com/how-to-enable-dark-mode-in-office-2021-365
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Common" = @{
        "UI Theme" = 0x00000006  # follow system
    }
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Shared Tools\Proofing Tools\1.0\Office" = @{
        OneNoteSpellingOptions = 0x00000002
        WordSpellingOptions    = 0x00000005
    }
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Common\AutoCorrect" = @{
        CapitalizeNamesOfDays      = 0x00000000
        CapitalizeSentence         = 0x00000000
        CorrectTwoInitialCapitals  = 0x00000000
    }
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Common\LanguageResources" = @{
        NotificationsNeverShowAgainLanguages = "hu-HU"  # TODO make configurable
    }

    # outlook
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\Calendar" = @{
        "Alter Calendar Lang"    = 0x00000409  # (1033)
        "Alter Calendar Type"    = 0x00000001
        "CalDefStart"            = 0x0000021c  #  (540)
        "CalDefEnd"              = 0x00000438  # (1080)
        "FirstDOW"               = 0x00000001
        "SelectCalendarViewType" = 0x00000000
        "WorkDay"                = 0x0000007c  #  (124)
        "WeekNum"                = 0x00000001  #  (1)
    }
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\Outlook\Settings\Data\" = @{
        # I have found these weird json entries using newer versions of Outlook. 
        # I simply set the id to "" and isFirstSync to "true" and it worked.
        "global_Calendar_FirstDayOfWeek" =    '{"name":"Calendar_FirstDayOfWeek",   "itemClass":"roamingsetting","id":"","scope":"global","parentSetting":"","secondaryKey":"",                          "status":"SYNCEDTOSERVICE","type":"Int", "timestamp":0,"metadata":"","value":"1",    "isFirstSync":"true","source":"UserOverride"}'
        "global_Calendar_FirstWeekOfYear" =   '{"name":"Calendar_FirstWeekOfYear",  "itemClass":"roamingsetting","id":"","scope":"global","parentSetting":"","secondaryKey":"Calendar_FirstWeekOfYear",  "status":"SYNCEDTOSERVICE","type":"Int", "timestamp":0,"metadata":"","value":"0",    "isFirstSync":"true","source":"UserOverride"}'
        "global_Calendar_WeekNum" =           '{"name":"Calendar_WeekNum",          "itemClass":"roamingsetting","id":"","scope":"global","parentSetting":"","secondaryKey":"Calendar_WeekNum",          "status":"SYNCEDTOSERVICE","type":"Int", "timestamp":0,"metadata":"","value":"0",    "isFirstSync":"true","source":"UserOverride"}'
        "global_Mail_ReadingPaneSelectItem" = '{"name":"Mail_ReadingPaneSelectItem","itemClass":"roamingsetting","id":"","scope":"global","parentSetting":"","secondaryKey":"Mail_ReadingPaneSelectItem","status":"SYNCEDTOSERVICE","type":"Bool","timestamp":0,"metadata":"","value":"false","isFirstSync":"true","source":"UserOverride"}'
    }
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\Conversations" = @{
        ConversationsOnInAllFoldersChangeNumber = 0x00000003
    }
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" = @{
        DatePickerMonths       = 0x00000001
        UseNewOutlook          = 0x00000000
        EnableSingleLineRibbon = 0x00000000
        EnablePreviewPlace     = 0x00000000
        DefaultLayoutApplied   = 0x00000020
    }
}

Configuration MSOfficeConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        foreach ($appName in @("OneNote", "Excel", "Word", "olkexplorer", "olkmailread"))
        {
            # https://social.technet.microsoft.com/Forums/en-US/ce8a0544-8fcc-4ab8-ac7f-e0c83960dce7/location-of-qat-quick-access-toolbar-officeui-files?forum=outlook
            File "$appName.officeUI"
            {
                Type            = 'File'
                SourcePath      = "$RepoRoot\config\ms_office\$appName.officeUI"
                DestinationPath = "$UserDir\AppData\Local\Microsoft\Office\$appName.officeUI"
                Ensure          = "Present"
                Checksum        = "SHA-1"
            }
        }
    }
}
ApplyDscConfiguration "MSOfficeConfig"

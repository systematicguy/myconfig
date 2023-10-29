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

# as seen on https://pastebin.com/AbaPjJHa after https://www.reddit.com/r/sysadmin/comments/14kdpcj/set_open_hyperlinks_from_outlook_in_to_default/
# TODO does not work:
# EnsureRegistry -Purpose "OutlookUseDefaultBrowser" -ValueType "Binary" -RegistryConfig @{
#     "HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Common\Links" = @{
#         BrowserChoice     = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000005c6f7248d1111e4cbd5a39799128f3e6000000004a0000005600320020004d006900630072006f0073006f006600740020003300360035002000420072006f007700730065007200200055007300650072002000430068006f006900630065000000106600000001000020000000c1f9967e98d143d19772b5f604b4b5d6ba9d7856e546dc68af3166e790089154000000000e80000000020000200000008b56d733f43283b44946fe4d2b4f80b24dde1d377143f390a88adcdb46d3062e100000002f229739ba74b7b214bcb359a6b31d1340000000ff2aa7b33ae5ed984dc751a1a84d6c33b0c1248f5fc9f376823eb21266858ae7b0c9dd11570431aa98ec1fa9fcf677943d5edac843a626b7"
#         BrowserChoiceTime = "d2eb7d175309da01"
#     }
# } 

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

. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

Configuration MSOfficeConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        foreach ($appName in @("OneNote", "Excel", "Word", "olkexplorer"))
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

        Registry OneNoteSpellingOptions
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            
            Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Shared Tools\Proofing Tools\1.0\Office"
            ValueName = "OneNoteSpellingOptions"
            ValueType = "Dword"
            ValueData = 0x00000002
        }

        Registry WordSpellingOptions
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            
            Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Shared Tools\Proofing Tools\1.0\Office"
            ValueName = "WordSpellingOptions"
            ValueType = "Dword"
            ValueData = 0x00000005
        }

        foreach ($valueName in @("CapitalizeNamesOfDays", "CapitalizeSentence", "CorrectTwoInitialCapitals"))
        {
            Registry "OfficeCommonAutoCorrect_$valueName"
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Common\AutoCorrect"
                ValueName = $valueName
                ValueType = "Dword"
                ValueData = 0x00000000
            }
        }

        Registry "OfficeCommon_NotificationsNeverShowAgainLanguages"
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            
            Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Common\LanguageResources"
            ValueName = "NotificationsNeverShowAgainLanguages"
            ValueType = "String"
            ValueData = "hu-HU"  # TODO make configurable
        }

        # Outlook Calendar
        $outlookCalendar = @{
            "Alter Calendar Lang"    = 0x00000409  # (1033)
            "Alter Calendar Type"    = 0x00000001
            "CalDefStart"            = 0x0000021c  #  (540)
            "CalDefEnd"              = 0x00000438  # (1080)
            "FirstDOW"               = 0x00000001
            "SelectCalendarViewType" = 0x00000000
            "WorkDay"                = 0x0000007c  #  (124)
            "WeekNum"                = 0x00000001  #  (1)
        }
        foreach ($valueName in $outlookCalendar.Keys)
        {
            Registry "OutlookCalendar_$valueName"
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\Calendar"
                ValueName = $valueName
                ValueType = "Dword"
                ValueData = $outlookCalendar[$valueName]
            }
        }

        Registry "Outlook_ConversationsOnInAllFoldersChangeNumber"
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            
            Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\Conversations"
            ValueName = "ConversationsOnInAllFoldersChangeNumber"
            ValueType = "Dword"
            ValueData = 0x00000003
        }

        # Outlook Preferences
        $outlookPreferences = @{
            "DatePickerMonths"       = 0x00000001
            "UseNewOutlook"          = 0x00000000
            "EnableSingleLineRibbon" = 0x00000000
            "EnablePreviewPlace"     = 0x00000000
            "DefaultLayoutApplied"   = 0x00000020
        }
        foreach ($valueName in $outlookPreferences.Keys)
        {
            Registry "OutlookPreferences_$valueName"
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences"
                ValueName = $valueName
                ValueType = "Dword"
                ValueData = $outlookPreferences[$valueName]
            }
        }
    }
}

ApplyDscConfiguration "MSOfficeConfig"
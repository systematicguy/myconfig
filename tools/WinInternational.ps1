. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

Configuration InternationalConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        # https://renenyffenegger.ch/notes/Windows/registry/tree/HKEY_CURRENT_USER/Control-Panel/International/index
        $internationalSettings = @{
            "Locale"          = "00000409"  # English (United States)
            "LocaleName"      = "en-US"
            
            "iDate"           = "2"  # year, month, day
            "iFirstDayOfWeek" = "0"  # Monday
            "iLZero"          = "1"  # leading zeros
            "iMeasure"        = "0"  # metric
            "iTime"           = "0"  # 24h
            "iTLZero"         = "0"  # no leading zeros
            "sDate"           = "-"  # date separator ISO 8601
            "sLongDate"       = "dddd, d MMMM yyyy"
            "sShortDate"      = "yyyy-MM-dd"  # ISO 8601
            "sShortTime"      = "H:mm"
            "sTimeFormat"     = "H:mm:ss"
            "sYearMonth"      = "MMMM yyyy"
            "sTime"           = ":"  # time separator

            "sLanguage"       = "ENU"  # TODO language
            
            "iPaperSize"      = "9"  # A4
            
            "sDecimal"        = "."  # decimal separator
            "sList"           = ","  # list separator, influences Excel
            "sMonThousandSep" = ","  # thousand separator
            "sThousand"       = ","  # thousand separator

        }
        foreach ($valueName in $internationalSettings.Keys)
        {
            Registry "International_$valueName"
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "Computer\HKEY_CURRENT_USER\Control Panel\International"
                ValueName = $valueName
                ValueType = "String"
                ValueData = $internationalSettings[$valueName]
            }
        }

        $internationalGeoSettings = @{
            "Name"   = "CH"
            "Nation" = "223"
        }
        foreach ($valueName in $internationalGeoSettings.Keys)
        {
            Registry "International_Geo_$valueName"
            {
                PsDscRunAsCredential = $UserCredentialAtComputerDomain
                
                Key       = "Computer\HKEY_CURRENT_USER\Control Panel\International\Geo"
                ValueName = $valueName
                ValueType = "String"
                ValueData = $internationalGeoSettings[$valueName]
            }
        }

    }
}

ApplyDscConfiguration "InternationalConfig"


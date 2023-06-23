. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Registry.ps1

EnsureRegistry -Purpose "InternationalConfig" -RegistryConfig @{
    "HKEY_CURRENT_USER\Control Panel\International" = @{
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
    "HKEY_CURRENT_USER\Control Panel\International\Geo" = @{
        "Name"   = "CH"
        "Nation" = "223"
    }
}

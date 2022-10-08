if ($_AlreadySourcedTotalCommander -ne $null) { return } else { $_AlreadySourcedTotalCommander = $true }

. $PSScriptRoot\..\..\windows\Environment.ps1

# existing ini file location: https://ghisler.ch/board/viewtopic.php?t=26830
$winCmdPath = "$UserDir\AppData\Roaming\GHISLER\wincmd.ini"

. $PSScriptRoot\VsCode.ps1

$totalCmdIniConfig = @{
    Configuration = @{
        Editor                    = "`"$VsCodeExePath`" `"%1`"";
        DarkMode                  = "1";
        RenameSelOnlyName         = "1";
        AltSearch                 = "3";
        QuickSearchMatchBeginning = "0";
        QuickSearchExactMatch     = "0";
        SizeStyle                 = "3";
        SizeFooter                = "3";
        SoundDelay                = "-10";
        VerifyCopy                = "1";
        ShowHiddenSystem          = "1";
        QuickSearchAutoFilter     = "1";
        UseLongNames              = "1";
        IconOverlays              = "1";
        DirTabOptions             = "1";
        DirTabRevert              = "1977";
        DirTabFilters             = "1";
        WatchDirs                 = "51";
    };
    Confirmation = @{
        deleteDirs        = "0";
        OverwriteFiles    = "1";
        OverwriteReadonly = "0";
        OverwriteHidSys   = "0";
        MouseActions      = "1";
    };
    Tabstops = @{
        AdjustWidth = "1";
    };
    Layout = @{
        ButtonBar             = "1";
        ButtonBarVertical     = "1";
        DriveBar1             = "1";
        DriveBar2             = "1";
        DriveBarFlat          = "1";
        InterfaceFlat         = "1";
        DriveCombo            = "1";
        DirectoryTabs         = "1";
        XPthemeBg             = "1";
        CurDir                = "1";
        TabHeader             = "1";
        StatusBar             = "1";
        CmdLine               = "1";
        KeyButtons            = "1";
        HistoryHotlistButtons = "1";
        BreadCrumbBar         = "1";
    };
}

Configuration TotalCommanderInstallation
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco 

    Node "localhost"
    {
        cChocoPackageInstaller TotalCommander
        {
            Name = "totalcommander"
        }
    }
}

Configuration TotalCommanderConfiguration
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName FileContentDsc

    Node "localhost"
    {
        foreach ($sectionKey in $totalCmdIniConfig.Keys)
        {
            foreach ($key in $totalCmdIniConfig[$sectionKey].Keys) 
            {
                IniSettingsFile "Tcmd_$sectionKey_$key"
                {
                    Path    = $winCmdPath
                    Section = "$sectionKey"
                    Key     = "$key"
                    Text    = $totalCmdIniConfig[$sectionKey][$key]
                }
            }
        }
    }
}


# TODO: plugins
# https://www.ghisler.ch/board/viewtopic.php?t=42019


TotalCommanderInstallation -Output $DscMofDir\TotalCommanderInstallation
Start-DscConfiguration -Path $DscMofDir\TotalCommanderInstallation -Wait -Force -Verbose

TotalCommanderConfiguration -Output $DscMofDir\TotalCommanderConfiguration
Start-DscConfiguration -Path $DscMofDir\TotalCommanderConfiguration -Wait -Force -Verbose

LogTodo -Message "Total Commander activation: place the wincmd.key file into the installation dir"
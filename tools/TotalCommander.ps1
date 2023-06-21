. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoToolsDir\Chocolatey.ps1
. $RepoRoot\windows\Downloader.ps1

. $RepoToolsDir\VsCode.ps1

# existing ini file location: https://ghisler.ch/board/viewtopic.php?t=26830
$winCmdParentDir = "$UserDir\AppData\Roaming\GHISLER"
$winCmdPath = "$winCmdParentDir\wincmd.ini"
$totalCmdPluginDir = "$UserBinDir\total_commander\plugins"

# https://www.ghisler.ch/wiki/index.php?title=Wincmd.ini
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
        DirTabOptions             = "1945";
        DirTabRevert              = "1";
        DirTabFilters             = "1";
        WatchDirs                 = "51";
        PluginBaseDir             = $totalCmdPluginDir;
        # AutoInstallPlugins        = "1";
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
ApplyDscConfiguration "TotalCommanderInstallation"

Configuration TotalCommanderConfiguration
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName FileContentDsc

    Node "localhost"
    {
        File WinCmdParentDir 
        {
            #Credential      = $UserCredentialAtComputerDomain
            Type            = "Directory"
            DestinationPath = "$winCmdParentDir"
            Ensure          = "Present"
        }

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
#ApplyDscConfiguration "TotalCommanderConfiguration"

# plugins: https://www.ghisler.com/plugins.htm
# https://www.ghisler.ch/board/viewtopic.php?t=42019

EnsureExtractedUrl `
    -Url "https://ghisler.fileburst.com/content/wdx_exif.zip" `
    -ExtractedDir "$totalCmdPluginDir\wdx\wdx_exif"
$contentPluginSettings = @{
    ContentPlugins = @{
        "0"        = "$totalCmdPluginDir\wdx\wdx_exif\exif.wdx"
        "0_detect" = "`"EXT=`"JPG`" | EXT=`"JPEG`" | EXT=`"TIFF`" | EXT=`"TIF`" | EXT=`"JPE`" | EXT=`"CRW`" | EXT=`"THM`" | EXT=`"CR2`" | EXT=`"CR3`" | EXT=`"DNG`" | EXT=`"NEF`"`""
        "0_flags"  = "0"
    }
    CustomFields = @{
        Titles      = "Pictures|Videos";
        AutoLoad    = "1";

        Widths1     = "181,30,-80,80,62,50,80";
        Headers1    = "Size\nCreation\nModDate\nCamMaker\nCamModel";
        Contents1   = "[=tc.size]\n[=tc.creationdate]\n[=tc.writedate]\n[=exif.Make]\n[=exif.Model]";
        Options1    = "-1|0|96";

        Widths2     = "181,30,-80,80,62";
        Headers2    = "Size\nCreation\nModDate";
        Contents2   = "[=tc.size]\n[=tc.creationdate]\n[=tc.writedate]";
        Options2    = "-1|0|96";
    }
}
Configuration TCmdContentPlugins
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName FileContentDsc

    Node "localhost"
    {
        foreach ($sectionKey in $contentPluginSettings.Keys)
        {
            foreach ($key in $contentPluginSettings[$sectionKey].Keys)
            {
                IniSettingsFile "TCmd_$sectionKey_$key"
                {
                    Path    = $winCmdPath
                    Section = "$sectionKey"
                    Key     = "$key"
                    Text    = $contentPluginSettings[$sectionKey][$key]
                }
            }
        }
    }
}
ApplyDscConfiguration "TCmdContentPlugins"

EnsureExtractedUrl `
    -Url "https://www.totalcommander.ch/win/fs/cloudplugin2.50.zip" `
    -ExtractedDir "$totalCmdPluginDir\wfx\cloudplugin"

LogTodo -Message "Total Commander activation: place the wincmd.key file into the installation dir"

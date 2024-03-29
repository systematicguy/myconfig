. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Downloader.ps1
. $RepoRoot\helpers\Ini.ps1
. $RepoRoot\helpers\Chocolatey.ps1

. $RepoToolsDir\VsCode.ps1

# existing ini file location: https://ghisler.ch/board/viewtopic.php?t=26830
$winCmdParentDir = "$UserDir\AppData\Roaming\GHISLER"
$winCmdPath = "$winCmdParentDir\wincmd.ini"
$totalCmdPluginDir = "$UserBinDir\total_commander\plugins"

EnsureChocoPackage -Name "totalcommander"

Configuration TotalCommanderConfigDir
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName FileContentDsc

    Node "localhost"
    {
        File WinCmdParentDir 
        {
            #Credential      = $UserCredential
            Type            = "Directory"
            DestinationPath = "$winCmdParentDir"
            Ensure          = "Present"
        }
    }
}
ApplyDscConfiguration "TotalCommanderConfigDir"

# https://www.ghisler.ch/wiki/index.php?title=Wincmd.ini
$totalCmdIniConfig = @{
    Configuration = @{
        Editor                    = "`"`"$VsCodeExePath`" `"%1`""
        DarkMode                  = "1"
        RenameSelOnlyName         = "1"
        AltSearch                 = "3"
        QuickSearchMatchBeginning = "0"
        QuickSearchExactMatch     = "0"
        SizeStyle                 = "3"
        SizeFooter                = "3"
        SoundDelay                = "-10"
        VerifyCopy                = "1"
        ShowHiddenSystem          = "1"
        QuickSearchAutoFilter     = "1"
        UseLongNames              = "1"
        IconOverlays              = "1"
        DirTabOptions             = "1945"
        DirTabRevert              = "1"
        DirTabFilters             = "1"
        WatchDirs                 = "51"
        PluginBaseDir             = $totalCmdPluginDir
        # AutoInstallPlugins        = "1"
    }
    Confirmation = @{
        deleteDirs        = "0"
        OverwriteFiles    = "1"
        OverwriteReadonly = "0"
        OverwriteHidSys   = "0"
        MouseActions      = "1"
    }
    Tabstops = @{
        AdjustWidth = "1";
    }
    Layout = @{
        ButtonBar             = "1"
        ButtonBarVertical     = "1"
        DriveBar1             = "1"
        DriveBar2             = "1"
        DriveBarFlat          = "1"
        InterfaceFlat         = "1"
        DriveCombo            = "1"
        DirectoryTabs         = "1"
        XPthemeBg             = "1"
        CurDir                = "1"
        TabHeader             = "1"
        StatusBar             = "1"
        CmdLine               = "1"
        KeyButtons            = "1"
        HistoryHotlistButtons = "1"
        BreadCrumbBar         = "1"
    }
    searches = @{
        not_older_than_1_hour_SearchFor   = ""
        not_older_than_1_hour_SearchIn    = "c:\"
        not_older_than_1_hour_SearchText  = ""
        not_older_than_1_hour_SearchFlags = "0|002002000020|||1|0|||||0000|"
    }
    Colors = @{
        ColorFilter1      = ">not_older_than_1_hour"
        ColorFilter1Color = "16711680"
    }
    DirMenu = @{
        menu1 = "dev"
        cmd1  = "cd $UserDir\dev"

        menu2 = "devp"
        cmd2  = "cd $UserDir\devp"
        
        menu3 = "Downloads"
        cmd3  = "cd $UserDir\Downloads"
        
        menu4 = "myconfig"
        cmd4  = "cd $RepoRoot"
        
        menu5 = "Registry"
        cmd5  = "cd \\\Registry"
    }
}
EnsureIniConfig -Path $winCmdPath -IniConfig $totalCmdIniConfig

# plugins: https://www.ghisler.com/plugins.htm
# https://www.ghisler.ch/board/viewtopic.php?t=42019

EnsureExtractedUrl `
    -Url "https://ghisler.fileburst.com/content/wdx_exif.zip" `
    -ExtractedDir "$totalCmdPluginDir\wdx\wdx_exif"
EnsureIniConfig -Path $winCmdPath -IniConfig @{
    ContentPlugins = @{
        "0"        = "$totalCmdPluginDir\wdx\wdx_exif\exif.wdx"
        "0_detect" = "`"EXT=`"JPG`" | EXT=`"JPEG`" | EXT=`"TIFF`" | EXT=`"TIF`" | EXT=`"JPE`" | EXT=`"CRW`" | EXT=`"THM`" | EXT=`"CR2`" | EXT=`"CR3`" | EXT=`"DNG`" | EXT=`"NEF`"`""
        "0_flags"  = "0"
    }
    CustomFields = @{
        Titles      = "Pictures|Videos"
        AutoLoad    = "1"

        Widths1     = "181,30,-80,80,62,50,80"
        Headers1    = "Size\nCreation\nModDate\nCamMaker\nCamModel"
        Contents1   = "[=tc.size]\n[=tc.creationdate]\n[=tc.writedate]\n[=exif.Make]\n[=exif.Model]"
        Options1    = "-1|0|96"

        Widths2     = "181,30,-80,80,62"
        Headers2    = "Size\nCreation\nModDate"
        Contents2   = "[=tc.size]\n[=tc.creationdate]\n[=tc.writedate]"
        Options2    = "-1|0|96"
    }
}

EnsureExtractedUrl `
    -Url "https://www.totalcommander.ch/win/fs/cloudplugin2.50.zip" `
    -ExtractedDir "$totalCmdPluginDir\wfx\cloudplugin"
EnsureExtractedUrl `
    -Url "https://ghisler.fileburst.com/fsplugins/wfx_registry.zip" `
    -ExtractedDir "$totalCmdPluginDir\wfx\Registry"
EnsureIniConfig -Path $winCmdPath -IniConfig @{
    FileSystemPlugins = @{
        "Cloud"    = "$totalCmdPluginDir\wfx\cloudplugin\cloudplugin.wfx";
        "Registry" = "$totalCmdPluginDir\wfx\Registry\registry.wfx";
    }
}

#TODO checkout:
# packer plugins
#  7zip https://ghisler.fileburst.com/plugins/wcx_7zip.zip
#  GIF https://ghisler.fileburst.com/plugins/gifwcx.zip
#  ISO https://ghisler.fileburst.com/plugins/iso_plugin.zip
#
# file system plugins
#  Back2Life https://ghisler.fileburst.com/fsplugins/b2l4tc.zip ($10) restore erased files from FAT and NTFS
#  PROC https://www.diskinternals.com/download/diskinternals_procfs.zip process explorer with window detection
#  SFTP https://www.totalcommander.ch/win/fs/sftpplug.zip
#  WebDAV https://ghisler.fileburst.com/fsplugins/webdav.zip
#
# lister plugins
#  fileinfo http://fg.tcplugins.free.fr/fileinfo.htm Version, dlls, etc
#  Imagine https://ghisler.fileburst.com/lsplugins/wlx_imagine_x64.zip GIF viewer, etc.
#  SQLiteViewer https://ghisler.fileburst.com/progman13/wlx_SQLiteViewer.zip
#
# content plugins
#  MIME Info https://ghisler.fileburst.com/progman13/wdx_MIMEInfo.zip
#  ShellDetails https://ghisler.fileburst.com/content/wdx_shelldetails.zip all Windows Explorer fields
#  xPDFSearch https://ghisler.fileburst.com/content/wdx_xpdfsearch.zip

LogTodo -Message "Total Commander activation: place the wincmd.key file into the installation dir"

$winCmdPath = "C:\Users\horvathda\AppData\Roaming\GHISLER\wincmd.ini"

configuration TotalCommanderDependencies
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco 

    Node "localhost"
    {
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\ProgramData\chocolatey"
        }

        cChocoPackageInstaller InstallVsCode
        {
            Name      = "vscode"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }
    }
}

configuration TotalCommanderInstallation
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

configuration TotalCommanderConfiguration
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco 
    Import-DSCResource -ModuleName FileContentDsc

    Node "localhost"
    {
        # Configuration section
        IniSettingsFile Tcmd_Configuration_Editor
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "Editor"
            Text    = '"C:\Program Files\Microsoft VS Code\Code.exe" "%1"'
        }

        IniSettingsFile Tcmd_Configuration_DarkMode
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "DarkMode"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Configuration_RenameSelOnlyName
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "RenameSelOnlyName"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Configuration_AltSearch
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "AltSearch"
            Text    = "3"
        }

        IniSettingsFile Tcmd_Configuration_QuickSearchMatchBeginning
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "QuickSearchMatchBeginning"
            Text    = "0"
        }

        IniSettingsFile Tcmd_Configuration_QuickSearchExactMatch
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "QuickSearchExactMatch"
            Text    = "0"
        }

        IniSettingsFile Tcmd_Configuration_SizeStyle
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "SizeStyle"
            Text    = "3"
        }

        IniSettingsFile Tcmd_Configuration_SizeFooter
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "SizeFooter"
            Text    = "3"
        }

        IniSettingsFile Tcmd_Configuration_SoundDelay
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "SoundDelay"
            Text    = "-10"
        }

        IniSettingsFile Tcmd_Configuration_VerifyCopy
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "VerifyCopy"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Configuration_ShowHiddenSystem
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "ShowHiddenSystem"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Configuration_QuickSearchAutoFilter
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "QuickSearchAutoFilter"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Configuration_UseLongNames
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "UseLongNames"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Configuration_IconOverlays
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "IconOverlays"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Configuration_DirTabOptions
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "DirTabOptions"
            Text    = "1977"
        }

        IniSettingsFile Tcmd_Configuration_DirTabRevert
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "DirTabRevert"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Configuration_DirTabFilters
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "DirTabFilters"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Configuration_WatchDirs
        {
            Path    = $winCmdPath
            Section = "Configuration"
            Key     = "WatchDirs"
            Text    = "51"
        }

        # Confirmation section
        IniSettingsFile Tcmd_Confirmation_DeleteDirs
        {
            Path    = $winCmdPath
            Section = "Confirmation"
            Key     = "deleteDirs"
            Text    = "0"
        }

        IniSettingsFile Tcmd_Confirmation_OverwriteFiles
        {
            Path    = $winCmdPath
            Section = "Confirmation"
            Key     = "OverwriteFiles"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Confirmation_OverwriteReadonly
        {
            Path    = $winCmdPath
            Section = "Confirmation"
            Key     = "OverwriteReadonly"
            Text    = "0"
        }

        IniSettingsFile Tcmd_Confirmation_OverwriteHidSys
        {
            Path    = $winCmdPath
            Section = "Confirmation"
            Key     = "OverwriteHidSys"
            Text    = "0"
        }

        IniSettingsFile Tcmd_Confirmation_MouseActions
        {
            Path    = $winCmdPath
            Section = "Confirmation"
            Key     = "MouseActions"
            Text    = "1"
        }

        # Tabstops section
        IniSettingsFile Tcmd_Tabstops_AdjustWidth
        {
            Path    = $winCmdPath
            Section = "Tabstops"
            Key     = "AdjustWidth"
            Text    = "1"
        }

        # Layout section
        IniSettingsFile Tcmd_Layout_ButtonBar
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "ButtonBar"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_ButtonBarVertical
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "ButtonBarVertical"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_DriveBar1
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "DriveBar1"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_DriveBar2
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "DriveBar2"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_DriveBarFlat
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "DriveBarFlat"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_InterfaceFlat
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "InterfaceFlat"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_DriveCombo
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "DriveCombo"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_DirectoryTabs
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "DirectoryTabs"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_XPthemeBg
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "XPthemeBg"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_CurDir
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "CurDir"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_TabHeader
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "TabHeader"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_StatusBar
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "StatusBar"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_CmdLine
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "CmdLine"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_KeyButtons
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "KeyButtons"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_HistoryHotlistButtons
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "HistoryHotlistButtons"
            Text    = "1"
        }

        IniSettingsFile Tcmd_Layout_BreadCrumbBar
        {
            Path    = $winCmdPath
            Section = "Layout"
            Key     = "BreadCrumbBar"
            Text    = "1"
        }
    }
}

# Compile the configuration file to a MOF format
TotalCommanderDependencies
TotalCommanderInstallation
TotalCommanderConfiguration

# Run the configuration on localhost
Start-DscConfiguration -Path .\TotalCommanderDependencies -Wait -Force -Verbose
Start-DscConfiguration -Path .\TotalCommanderInstallation -Wait -Force -Verbose
Start-DscConfiguration -Path .\TotalCommanderConfiguration -Wait -Force -Verbose
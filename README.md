# Prerequisites
The following might be needed even if we only do everything only locally:
```
PS > Set-WsManQuickConfig -Force
```
See [./machine/corp/PrepElevated.ps1]()

## DSC Powershell version lesson learned
https://learn.microsoft.com/en-us/powershell/scripting/dsc/overview?view=powershell-7.2

They have removed DSC from 7.2: https://learn.microsoft.com/en-us/powershell/scripting/dsc/overview?view=powershell-7.2

The lowest installable version is 2.0.5 from the gallery.
https://www.powershellgallery.com/packages?q=PSDesiredStateConfiguration

Anyways, I tried with 7.2 as admin, it partially worked, but not any more once started to use cChoco.

With version 5 all stuff works.


# Useful resources

## DSC howto, show-case
- https://learn.microsoft.com/en-us/powershell/dsc/getting-started/wingettingstarted?view=dsc-1.1
- https://www.tutorialspoint.com/powershell-desired-state-configuration
- https://octopus.com/blog/getting-started-with-powershell-dsc
- https://4sysops.com/archives/powershell-desired-state-configuration-dsc-part-2-setup/
- https://mehic.se/2019/04/16/desired-state-configuration-dsc-get-started/
- https://stackoverflow.com/questions/39460820/how-to-run-a-powershell-dsc-script-locally

## Notable examples from this repo

- [./machine/corp/BaseMachineConfig.ps1]()
- [./machine/corp/AutoDarkMode.ps1]()
- [./machine/corp/TotalCommander.ps1]()

## Get-DscResource
```
PS > Get-DscResource

ImplementedAs   Name                      ModuleName                     Version    Properties
-------------   ----                      ----------                     -------    ----------
Binary          File                                                                {DestinationPath, Attributes, Checksum, Content...
Binary          SignatureValidation                                                 {SignedItemType, TrustedStorePath}
PowerShell      cChocoConfig              cChoco                         2.5.0.0    {ConfigName, DependsOn, Ensure, PsDscRunAsCrede...
PowerShell      cChocoFeature             cChoco                         2.5.0.0    {FeatureName, DependsOn, Ensure, PsDscRunAsCred...
PowerShell      cChocoInstaller           cChoco                         2.5.0.0    {InstallDir, ChocoInstallScriptUrl, DependsOn, ...
PowerShell      cChocoPackageInstaller    cChoco                         2.5.0.0    {Name, AutoUpgrade, chocoParams, DependsOn...}
Composite       cChocoPackageInstallerSet cChoco                         2.5.0.0    {DependsOn, PsDscRunAsCredential, Name, Ensure...}
PowerShell      cChocoSource              cChoco                         2.5.0.0    {Name, Credentials, DependsOn, Ensure...}
PowerShell      IniSettingsFile           FileContentDsc                 1.3.0.151  {Key, Path, Section, DependsOn...}
PowerShell      KeyValuePairFile          FileContentDsc                 1.3.0.151  {Name, Path, DependsOn, Encoding...}
PowerShell      ReplaceText               FileContentDsc                 1.3.0.151  {Path, Search, AllowAppend, DependsOn...}
PowerShell      PackageManagement         PackageManagement              1.0.0.1    {Name, AdditionalParameters, DependsOn, Ensure...}
PowerShell      PackageManagementSource   PackageManagement              1.0.0.1    {Name, ProviderName, SourceUri, DependsOn...}
PowerShell      Archive                   PSDesiredStateConfiguration    1.1        {Destination, Path, Checksum, Credential...}
PowerShell      Environment               PSDesiredStateConfiguration    1.1        {Name, DependsOn, Ensure, Path...}
PowerShell      Group                     PSDesiredStateConfiguration    1.1        {GroupName, Credential, DependsOn, Description...}
Composite       GroupSet                  PSDesiredStateConfiguration    1.1        {DependsOn, PsDscRunAsCredential, GroupName, En...
Binary          Log                       PSDesiredStateConfiguration    1.1        {Message, DependsOn, PsDscRunAsCredential}
PowerShell      Package                   PSDesiredStateConfiguration    1.1        {Name, Path, ProductId, Arguments...}
Composite       ProcessSet                PSDesiredStateConfiguration    1.1        {DependsOn, PsDscRunAsCredential, Path, Credent...
PowerShell      Registry                  PSDesiredStateConfiguration    1.1        {Key, ValueName, DependsOn, Ensure...}
PowerShell      Script                    PSDesiredStateConfiguration    1.1        {GetScript, SetScript, TestScript, Credential...}
PowerShell      Service                   PSDesiredStateConfiguration    1.1        {Name, BuiltInAccount, Credential, Dependencies...
Composite       ServiceSet                PSDesiredStateConfiguration    1.1        {DependsOn, PsDscRunAsCredential, Name, Startup...
PowerShell      User                      PSDesiredStateConfiguration    1.1        {UserName, DependsOn, Description, Disabled...}
PowerShell      WaitForAll                PSDesiredStateConfiguration    1.1        {NodeName, ResourceName, DependsOn, PsDscRunAsC...
PowerShell      WaitForAny                PSDesiredStateConfiguration    1.1        {NodeName, ResourceName, DependsOn, PsDscRunAsC...
PowerShell      WaitForSome               PSDesiredStateConfiguration    1.1        {NodeCount, NodeName, ResourceName, DependsOn...}
PowerShell      WindowsFeature            PSDesiredStateConfiguration    1.1        {Name, Credential, DependsOn, Ensure...}
Composite       WindowsFeatureSet         PSDesiredStateConfiguration    1.1        {DependsOn, PsDscRunAsCredential, Name, Ensure...}
PowerShell      WindowsOptionalFeature    PSDesiredStateConfiguration    1.1        {Name, DependsOn, Ensure, LogLevel...}
Composite       WindowsOptionalFeatureSet PSDesiredStateConfiguration    1.1        {DependsOn, PsDscRunAsCredential, Name, Ensure...}
PowerShell      WindowsPackageCab         PSDesiredStateConfiguration    1.1        {Ensure, Name, SourcePath, DependsOn...}
PowerShell      WindowsProcess            PSDesiredStateConfiguration    1.1        {Arguments, Path, Credential, DependsOn...}
```

```
> Get-DscResource -Name File | Select -ExpandProperty Properties

Name                 PropertyType   IsMandatory Values
----                 ------------   ----------- ------
DestinationPath      [string]              True {}
Attributes           [string[]]           False {Archive, Hidden, ReadOnly, System}
Checksum             [string]             False {CreatedDate, ModifiedDate, SHA-1, SHA-256...}
Contents             [string]             False {}
Credential           [PSCredential]       False {}
DependsOn            [string[]]           False {}
Ensure               [string]             False {Absent, Present}
Force                [bool]               False {}
MatchSource          [bool]               False {}
PsDscRunAsCredential [PSCredential]       False {}
Recurse              [bool]               False {}
SourcePath           [string]             False {}
Type                 [string]             False {Directory, File}
```

## DSC File Resource
https://learn.microsoft.com/en-us/powershell/dsc/reference/resources/windows/fileresource?view=dsc-1.1

## DSC Script Resource
https://learn.microsoft.com/en-us/powershell/dsc/reference/resources/windows/scriptresource?view=dsc-1.1

https://powershellmagazine.com/2014/08/13/running-commands-as-another-user-using-dsc-script-resource/

### Impersonation, certificate-encrypted credentials
https://stackoverflow.com/questions/43040896/write-to-a-variable-from-dsc-script-resource

It is not possible to pass an external variable to Script.
Before executing every Test/Set function the LCM resets the state of the Runspace - i.e all variables are cleared. Therefore if you want to pass information, the best way is to write to a file and read from it.

https://blog.jermdavis.dev/posts/2015/wait-who-is-dsc-running-as-again

https://learn.microsoft.com/en-us/powershell/dsc/pull-server/secureMOF?view=dsc-1.1&viewFallbackFrom=powershell-7.2

https://learn.microsoft.com/en-us/powershell/dsc/configurations/configdata?view=dsc-1.1

https://serverfault.com/questions/632390/protecting-credentials-in-desired-state-configuration-using-certificates

## DSC Choco
https://www.powershellgallery.com/packages/cChoco/2.3.1.0/Content/ExampleConfig.ps1

https://docs.chocolatey.org/en-us/features/integrations#powershell-dsc

```
Install-Module -Name cChoco
```

```
configuration BaseMachineConfig
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

        cChocoPackageInstaller InstallGit
        {
            Name      = "git"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }

        # or

        cChocoPackageInstallerSet InstallSomeStuff
        {
            Ensure = 'Present'
            Name = @(
                "git"
                "vscode"
            )
            DependsOn = "[cChocoInstaller]installChoco"
        }
    }
}

```


## DSC IniSettingsFile
https://github.com/dsccommunity/FileContentDsc
```
Install-Module -Name FileContentDsc -Force
```

```
Configuration IniSettingsFile_SetPlainTextEntry_Config
{
    Import-DSCResource -ModuleName FileContentDsc

    Node localhost
    {
        IniSettingsFile SetLogging
        {
            Path    = 'c:\myapp\myapp.ini'
            Section = 'Logging'
            Key     = 'Level'
            Text    = 'Information'
        }
    }
}
```

## Yaml
https://github.com/cloudbase/powershell-yaml


```
Install-Module powershell-yaml

Get-Content .\tools\windows\auto_dark_mode\config.yaml | ConvertFrom-Yaml | ConvertTo-Yaml | Out-File "test.yaml"
```

## Merge Yaml
https://github.com/dfinke/PSYamlQuery

Note: don't install with powershell-yaml together at the same time.
```
Install-Package: The following commands are already available on this system:'ConvertTo-Yaml'. This module 'PSYamlQuery' may override the existing commands. If you still want to install this module 
'PSYamlQuery',
use -AllowClobber parameter.
```

```
choco install yq -y
Install-Module -Name PSYamlQuery
```

Look out! 
- To merge lists, use the `-Append` switch.
- Merging will leave keys having value in place.
So if you want to override, put your config first, then merge the target.
```
override.yml

a: simple
b: [1, 2]
d: hi

target.yml

a: something
b: [3, 4]
c:
  test: 2
  other: true
```
```
Merge-Yaml override.yml target.yml -Append
```
Result
```
a: simple
b: [1, 2, 3, 4]
d: hi
c:
  test: 2
  other: true

```

```
PS > Import-Yaml .\tools\windows\auto_dark_mode\config.yaml

AppsSwitch                : @{Component=; Enabled=True}
AutoThemeSwitchingEnabled : True
Autostart                 : @{Validate=True}
ColorFilterSwitch         : @{Component=; Enabled=False}
Events                    : @{DarkThemeOnBattery=False; SystemResumeTrigger=True}
GPUMonitoring             : @{Enabled=False; MonitorTimeSpanMin=1; Samples=1; Threshold=30}
Hotkeys                   : @{Enabled=False; ForceDarkHotkey=; ForceLightHotkey=; NoForceHotkey=}
Location                  : @{CustomLat=47.285561; CustomLon=7.94759; Enabled=True; PollingCooldownTimeSpan=1.00:00:00; SunriseOffsetMin=120; SunsetOffsetMin=-80; UseGeolocatorService=False}        
OfficeSwitch              : @{Component=; Enabled=True}
Sunrise                   : 11.10.2021 07:00:00
Sunset                    : 11.10.2021 20:00:00
SystemSwitch              : @{Component=; Enabled=True}
Tunable                   : @{BatterySliderDefaultValue=25; Debug=False; DebugTimerMessage=False; DisableEnergySaverOnThemeSwitch=False; ShowTrayIcon=True; UICulture=en; UseLogonTask=False}
Updater                   : @{AutoInstall=False; CheckOnStart=False; DaysBetweenUpdateCheck=7; DownloadBaseUrl=; Enabled=True; HashCustomUrl=; Silent=False; VersionQueryUrl=; ZipCustomUrl=}
WallpaperSwitch           : @{Component=; Enabled=False}
WindowsThemeMode          : @{DarkThemePath=; Enabled=False; LightThemePath=; MonitorActiveTheme=False}


PS > Import-Yaml .\tools\windows\auto_dark_mode\config.yaml AutoThemeSwitchingEnabled
True

PS > Import-Yaml .\tools\windows\auto_dark_mode\config.yaml SystemSwitch | ConvertTo-Yaml
Component:
  Mode: Switch
  TaskbarColorOnAdaptive: false     
  TaskbarColorWhenNonAdaptive: Light
  TaskbarSwitchDelay: 1200
Enabled: true
```

## About Docker
https://dscottraynsford.wordpress.com/2016/10/15/install-docker-on-windows-server-2016-using-dsc/
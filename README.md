# What is this
This is my 7th time to install almost the same set of tools and click through the configurations on a work laptop.
Frankly, I had enough.
- Enough of installing stuff, having opened 3 laptops.
- Enough of keeping settings in sync whenever my config evolves on one of my concurrent 3 work-laptops.
- Enough of spending time on my mother's/dad's/< insert random relative here >'s machine's random state whenever I need to troubleshoot it.

Even if I have been documenting every config for the past 10 yeears in my notes.

I know, this will take 3 to 5 years in total to touch the Big 3.

I am too lazy to go back to the old days (and I don't have the time or device).
 - When I spent 8 hours a day in ssh screens with vim.
 - Or the time when I was fighting a macbook for more than a year.

As of this writing (late 2022) I am using Windows and WSL, so the repo will resemble this.

So I am automating the hell out of my config. For myself. But feel free to use this if you want.

## Background
I have Software Engineering and DevOps background, the latter with a lot of exposure to
- Python, Powershell, Bash
- Puppet, Chocolatey, Ansible, Terraform, Docker
- Ini, json, yaml
- IntelliJ, Visual Studio Code, Vim

Scripted/compiled/configured software and tooling on Windows, Linux, even Mac.

This exposure will show on my structure and the technologies applied.

## Configuring your work machine is hard
- Even if I want to treat it as a cattle, it is still a pet. Sometimes there are parts that need to be left alone, so immutability is a no-no.
- It is also not enough to just put all your config files, GPOs, registries, heck, even tool binaries into version control or
some storage provider so you sync it everywhere.
    - Some of these will be user/domain/environment specific.
    - Some update will bring in/remove new/old settings, that you will want to make use of.
    - For me, tjhis approach would be dirty, and not elegant enough.
- I have to work with managed corporate workstations/laptops where although I have admin right, but cannot ditch all their managed config.
- My mantra is (taken from Zolaly): take as many defaults as possible, don't fight the stream too much, configure 15%.
    - I do have my quirks, where I really need my way all the way till death. But I keep these to a minimum.
    - I try to play nice with the ecosystem, always considering what is the most maintainable solution.

## Design Considerations
- Idempotence
- Additive config instead of replacing
    - State needs to be picked up dynamically
- Modularity, Single Responsibility Principle
- Dependencies as Directed Acyclic Graph (DAG), where
    - each node makes sense to grab and start
    - each node lists all of their dependencies
- Should not matter where you `cd`
- Don't Repeat Yourself (DRY)
    - Least amount of copy-pasting boilerplate, supporting code (e.g. dot-sourcing)
    - No amount of copy-pasting business-critical code/data (in this case config)
- Secure credentials at rest: no plaintext passwords
- Generalizing
    - Although I will compromise somewhat on that in this case, as this repo represents how I organize my setup

# Quick start
- Download: https://github.com/systematicguy/myconfig/archive/refs/heads/main.zip
- Unzip to somewhere (e.g. in your userfolder)
- Copy [local_config/UserConfig.template.psd1](./local_config/UserConfig.template.psd1) to `local_config/UserConfig.psd1`, edit it, remove the `Draft` entry.
- Start powershell 5 as Administrator
- Prepare your environment running [windows/OneTimeDscPrepare.ps1](./windows/OneTimeDscPrepare.ps1)
    ```
    windows\OneTimeDscPrepare.ps1
    ```
- Run
  - any of the tools ps1 script in the [tools](./tools/) folder in any order
  - any of the scripts in the [scripts](./scripts/) folder

    e.g.
    ```
    scripts\CorporateMachine.ps1

    # or

    tools\GitConfig.ps1
    tools\SshKey.ps1
    tools\TotalCommander.ps1
    ```

- Between runs you can avoid multiple prompts for credential via dotsourcing the variable into your scope:
    ```
    . .\helpers\UserCredential.ps1
    ```
- DSC generates mof files, containing only encrypted credentials. You can cleanup the certificate after configuration running [windows/DscCleanupCert.ps1](./windows/DscCleanupCert.ps1)
    ```
    windows\DscCleanupCert.ps1
    ```

# Desired State Configuration (DSC)
## Prerequisites
The following might be needed even if we only do everything only locally:
```
PS > Set-WsManQuickConfig -Force
```
See [windows/OneTimeDscPrepare.ps1](./windows/OneTimeDscPrepare.ps1)

## DSC Powershell version lesson learned
https://learn.microsoft.com/en-us/powershell/scripting/dsc/overview?view=powershell-7.2

They have removed DSC from 7.2: https://learn.microsoft.com/en-us/powershell/scripting/dsc/overview?view=powershell-7.2
https://learn.microsoft.com/en-us/powershell/dsc/overview?view=dsc-2.0

The lowest installable version is 2.0.5 from the gallery.
https://www.powershellgallery.com/packages?q=PSDesiredStateConfiguration

Anyways, I tried with 7.2 as admin, it partially worked, but not any more once started to use cChoco.

With version 5 all stuff works.

We cannot even uninstall Powershell 5.1 as it relies on .NET framework, with parts not opensourced,
whereas Powershell 7.2 is relying on .NET core.

Read more here: https://stackoverflow.com/questions/70931513/how-to-uninstall-powershell-5-1-on-windows-after-installing-72


# Useful resources

## DSC howto, show-case
- https://learn.microsoft.com/en-us/powershell/dsc/getting-started/wingettingstarted?view=dsc-1.1
- https://www.tutorialspoint.com/powershell-desired-state-configuration
- https://octopus.com/blog/getting-started-with-powershell-dsc
- https://4sysops.com/archives/powershell-desired-state-configuration-dsc-part-2-setup/
- https://mehic.se/2019/04/16/desired-state-configuration-dsc-get-started/
- https://stackoverflow.com/questions/39460820/how-to-run-a-powershell-dsc-script-locally

## Notable examples from this repo

- [scripts/CorporateMachine.ps1](./scripts/CorporateMachine.ps1)
- [tools/AutoDarkMode.ps1](./tools/AutoDarkMode.ps1)
- [tools/TotalCommander.ps1](./tools/TotalCommander.ps1)

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

## Credential vs PsDscRunAsCredential
https://learn.microsoft.com/en-us/powershell/dsc/configurations/configdatacredentials?view=dsc-1.1
https://learn.microsoft.com/en-us/powershell/dsc/configurations/runasuser?view=dsc-1.1

From the docs:
- DSC configuration resources run as Local System by default. However, some resources need a credential, for example when the Package resource needs to install software under a specific user account.
- Earlier resources used a hard-coded `Credential` property name to handle this. WMF 5.0 added an automatic `PsDscRunAsCredential` property for all resources. Newer resources and custom resources can use this automatic property instead of creating their own property for credentials.

```
PS > Get-DscResource -Name cChocopackageInstaller -Syntax
cChocoPackageInstaller [String] #ResourceName
{
    Name = [string]
    [AutoUpgrade = [bool]]
    [chocoParams = [string]]
    [DependsOn = [string[]]]
    [Ensure = [string]{ Absent | Present }]
    [MinimumVersion = [string]]
    [Params = [string]]
    [PsDscRunAsCredential = [PSCredential]]
    [Source = [string]]
    [Version = [string]]
}

PS > Get-DscResource -Name Script -Syntax
Script [String] #ResourceName
{
    GetScript = [string]
    SetScript = [string]
    TestScript = [string]
    [Credential = [PSCredential]]
    [DependsOn = [string[]]]
    [PsDscRunAsCredential = [PSCredential]]
}
```

## Redirect Script output
A DSC Configuration's Script output would make it fail.

- https://stackoverflow.com/questions/34049604/powershell-dsc-script-resource-fails-on-successful-execution-installing-apache
- https://stackoverflow.com/questions/18780956/suppress-console-output-in-powershell


`| Out-Null` was not enoguh to suppress all output, this is what worked for me:
```
command *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Exited with $LASTEXITCODE"
}
```

## ComputerManagement DSC
https://github.com/dsccommunity/ComputerManagementDsc

- PendingReboot
- PowerPlan
- ScheduledTask: https://www.powershellgallery.com/packages/ComputerManagementDsc/5.1.0.0/Content/Examples%5CResources%5CScheduledTask%5C1-CreateScheduledTaskOnce.ps1
- RemoteDesktopAdmin
- PowerShellExecutionPolicy
- SystemLocale
- WindowsCapability

## xPSDesiredStateConfiguration
https://github.com/dsccommunity/xPSDesiredStateConfiguration/blob/main/source/Examples/Resources/xRemoteFile/1-xRemoteFile_DownloadFile_Config.ps1

- xRemoteFile

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

## DSC json
https://github.com/mkht/DSCR_FileContent#examples-2
```
Install-Module -Name DSCR_FileContent -Force
```

```
Configuration Example1 {
    Import-DscResource -ModuleName DSCR_FileContent
    JsonFile String {
        Path = 'C:\Test.json'
        Key = 'StringValue'
        Value = '"Apple"'
    }
    JsonFile Bool {
        Path = 'C:\Test.json'
        Key = 'BoolValue'
        Value = 'true'
    }
    JsonFile Array {
        Path = 'C:\Test.json'
        Key = "ArrayValue"
        Value = '[true, 123, "banana"]'
    }
}

Configuration Example2 {
    Import-DscResource -ModuleName DSCR_FileContent
    JsonFile Dictionary {
        Path = 'C:\Test2.json'
        Key = 'KeyA'
        Value = '{"Ame":false,"Gura":true}'
    }
    JsonFile SubDictionary {
        Path = 'C:\Test2.json'
        Key = 'KeyB/SubKeyB'
        Value = 'Ina'
    }
    #If the key name contains a slash, please escape it with a backslash
    JsonFile SubDictionaryWithSlash {
        Path = 'C:\Test2.json'
        Key = 'KeyB/Sub\/\/Key'
        Value = 'Kiara'
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

## Downloading something via authenticated WebClient
Sometimes your corporate environment just won't let random connections go outbound, you have to use your credentials to download stuff.
```
Script InstallPoetry
{
    PsDscRunAsCredential = $UserCredential
    GetScript = {
        #Do Nothing
    }
    SetScript = {
        $proxyCredential = $using:UserCredentialAtAd
        $webClient = New-Object System.Net.WebClient
        $webClient.Proxy.Credentials = $proxyCredential.GetNetworkCredential()
        $webClient.DownloadString("https://install.python-poetry.org") | python | Out-File $using:outputFile -Encoding ASCII -Append
        if ($LASTEXITCODE -ne 0) {
            throw "Exited with $LASTEXITCODE"
        }
    }
    TestScript = {
        $false
    }
}
```
. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\ToIdentifier.ps1

function EnsureIniConfig {
    param (
        [string]$Path,
        [hashtable]$IniConfig
    )

    $iniConfigName = "IniConfig_$(PathToIdentifier $Path)"
    Configuration $iniConfigName
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DSCResource -ModuleName FileContentDsc

        Node "localhost"
        {
            foreach ($sectionKey in $IniConfig.Keys)
            {
                foreach ($key in $IniConfig[$sectionKey].Keys)
                {
                    IniSettingsFile "$($sectionKey)_$($key)"
                    {
                        Path    = $Path
                        Section = "$sectionKey"
                        Key     = "$key"
                        Text    = $IniConfig[$sectionKey][$key]
                    }
                }
            }
        }
    }
    Write-Host "Ensuring ini config is present in [$Path]..."
    ApplyDscConfiguration $iniConfigName
}

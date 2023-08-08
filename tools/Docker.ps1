. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\EnsureFile.ps1

. $RepoToolsDir\Chocolatey.ps1
. $RepoToolsDir\Jq.ps1
. $RepoToolsDir\Wsl.ps1

$dockerSettingsPath = "$UserDir\AppData\Roaming\Docker\settings.json"

Configuration DockerDesktop
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco
    Import-DscResource -ModuleName DSCR_FileContent
    
    Node "localhost"
    {
        cChocoPackageInstaller DockerDesktop
        {
            PsDscRunAsCredential = $UserCredential

            Name = "docker-desktop"
        }
    }
}
ApplyDscConfiguration "DockerDesktop"


# ==============================================================================================
# settings.json configuration
# docker desktop works with settings.json
#  it fills in missing settings on startup, doesn't overwrite existing ones
#  it adjusts settingsVersion upon startup
#  it doesn't save on simple exit, but does not play nice with settings.json edited while running
#  it crashes if settingsVersion key is missing, but is ok with a value of 0
$userDockerConfig = $UserConfig.DockerDesktop['settings.json']
$dockerFallbackSettingsVersion = $UserConfig.DockerDesktop.fallbackSettingsVersion
Write-Host "dockerFallbackSettingsVersion: $dockerFallbackSettingsVersion"
EnsureFile `
    -Path $dockerSettingsPath `
    -EncodingIfMissing ASCII `
    -ContentIfMissing "{`"settingsVersion`": $dockerFallbackSettingsVersion}"

# produce intermediate json file serializing the user's desired settings:
$userDockerConfigPath = "$DscWorkDir\userDockerConfig.json"
$userDockerConfig | ConvertTo-Json -Depth 100 | Set-Content $userDockerConfigPath -Encoding ASCII

# produce intermediate json file based on docker settings.json keeping only keys that are affected by the user:
$affectedDockerConfigPath = "$DscWorkDir\affectedDockerConfig.json"
jq.exe --argfile userConfig $userDockerConfigPath 'with_entries(select(.key | in($userConfig)))' $dockerSettingsPath `
    | Set-Content $affectedDockerConfigPath -Encoding ASCII

# calculate difference between affected and user config
$userDockerConfigAdjustments = jq.exe --argfile affected "$affectedDockerConfigPath" 'with_entries(select(.key as $k | .value != ($affected | .[$k])))' "$userDockerConfigPath"

# ConvertFrom-Json produces a PSCustomObject in PS 5.1, this is why following wizardry is needed:
if ((($userDockerConfigAdjustments | ConvertFrom-Json) | Get-Member -MemberType Properties).Count -eq 0) {
    Write-Host "[$dockerSettingsPath] is up to date"
} else {
    Write-Host "The following settings are missing or different in [$dockerSettingsPath]:"
    $userDockerConfigAdjustments | Write-Output

    $isDockerRunning = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
    if ($isDockerRunning) {
        if (-not $UserConfig.DockerDesktop.mayStopDockerDesktop) {
            Write-Host 'Docker Desktop is running, either set DockerDesktop.mayStopDockerDesktop = $true or stop it'
            throw 'Docker Desktop is running'
        }
        Write-Host 'Stopping Docker Desktop'
        Stop-Process -Name "Docker Desktop" -Force
    }
    Write-Host "Docker Desktop is not running, adjusting [$dockerSettingsPath] ..."
    # apply config on top of original, recursively merging objects
    jq.exe -s '.[0] * .[1]' $dockerSettingsPath $userDockerConfigPath `
        | Set-Content $dockerSettingsPath -Encoding ASCII
} 
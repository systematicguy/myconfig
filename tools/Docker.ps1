. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\EnsureFile.ps1
. $RepoRoot\helpers\Json.ps1

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

EnsureJsonConfig `
    -Path $dockerSettingsPath `
    -JsonConfigObject $UserConfig.DockerDesktop['settings.json'] `
    -ScriptBeforeApplying {
        $isDockerRunning = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
        if ($isDockerRunning) {
            if (-not $UserConfig.DockerDesktop.mayStopDockerDesktop) {
                Write-Host 'Docker Desktop is running, either set DockerDesktop.mayStopDockerDesktop = $true or stop it'
                throw 'Docker Desktop is running'
            }
            Write-Host 'Stopping Docker Desktop'
            Stop-Process -Name "Docker Desktop" -Force
        }
        Write-Host "Docker Desktop is not running"
    }

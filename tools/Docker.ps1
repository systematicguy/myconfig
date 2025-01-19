. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\Chocolatey.ps1
. $RepoRoot\helpers\EnsureFile.ps1
. $RepoRoot\helpers\Json.ps1

. $RepoToolsDir\Wsl.ps1

$dockerSettingsPath = "$UserDir\AppData\Roaming\Docker\settings.json"

EnsureChocoPackage -Name "docker-desktop"

# docker desktop works with settings.json
#  it fills in missing settings on startup, doesn't overwrite existing ones
#  it adjusts settingsVersion upon startup
#  it doesn't save on simple exit, but does not play nice with settings.json edited while running
#  it crashes if settingsVersion key is missing, but is ok with a value of 0
$dockerFallbackSettingsVersion = $UserConfig.DockerDesktop.fallbackSettingsVersion
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

# TODO exclude from Windows Defender:
# - dev folder
# - C:\Program Files\Docker\Docker\Docker Desktop.exe file
# - C:\Program Files\Docker\Docker\DockerCli.exe file
# - C:\Users\...\AppData\Local\Docker\wsl folder
# - c:\Users\david\AppData\Roaming\Docker\
# - c:\Users\david\AppData\Roaming\Docker Desktop\
# - c:\Users\david\.docker\
# - pycharm folder
# - pycharm indexing folder
#  https://docs.docker.com/engine/security/antivirus/
#  https://forums.docker.com/t/windows-defenderreal-time-protection-cripples-server-while-docker-is-running/64904
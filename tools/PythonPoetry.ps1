. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoToolsDir\PowershellConfig.ps1
. $RepoToolsDir\Pyenv.ps1

$desiredPoetryVersion = $UserConfig.Python.PoetryVersion
$desiredPathElement = "$UserDir\AppData\Roaming\Python\Scripts"

$outputFile = "$DscWorkDir\PoetryInstall.txt"
"------------------------------------------" | Out-File $outputFile -Encoding ASCII
Configuration PythonPoetry
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName FileContentDsc

    Node "localhost"
    {
        Script InstallPoetry
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                $desiredPoetryVersion = $using:desiredPoetryVersion
                if ($desiredPoetryVersion -ne "") {
                    $env:POETRY_VERSION = $desiredPoetryVersion
                }
                $proxyCredential = $using:UserCredentialAtAd
                $webClient = New-Object System.Net.WebClient
                $webClient.Proxy.Credentials = $proxyCredential.GetNetworkCredential()
                $webClient.DownloadString("https://install.python-poetry.org") | python | Out-File $using:outputFile -Encoding ASCII -Append
                if ($LASTEXITCODE -ne 0) {
                    throw "Exited with $LASTEXITCODE"
                }
            }
            TestScript = {
                try {
                    $foundPoetryVersionString = (poetry --version)
                } catch {
                    $foundPoetryVersionString = $null
                }
                $foundPoetryVersionString -ne $null  # emit $true if already installed
            }
        }

        Script PoetryOnPath
        {
            DependsOn            = "[Script]InstallPoetry"
            PsDscRunAsCredential = $UserCredentialAtComputerDomain

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                $desiredPathElement = $using:desiredPathElement
                $newPath = [Environment]::GetEnvironmentVariable("PATH", "User") + [IO.Path]::PathSeparator + $desiredPathElement
                [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
            }
            TestScript = {
                $desiredPathElement = $using:desiredPathElement
                [System.Environment]::GetEnvironmentVariable('PATH', 'User').ToLower().Split([IO.Path]::PathSeparator).Contains($desiredPathElement.ToLower())
            }
        }

        # TODO: implement version parsing, and uncomment the next:
        # Script UpdatePoetry
        # {
        #     PsDscRunAsCredential = $UserCredentialAtComputerDomain
        #     GetScript = {
        #         #Do Nothing
        #     }
        #     SetScript = {
        #         $desiredPoetryVersion = $using:desiredPoetryVersion
        #         poetry self update $using:desiredPoetryVersion | Out-File $using:outputFile -Encoding ASCII -Append
        #         if ($LASTEXITCODE -ne 0) {
        #             throw "Exited with $LASTEXITCODE"
        #         }
        #     }
        #     TestScript = {
        #         $desiredPoetryVersion = $using:desiredPoetryVersion
        #         $foundPoetryVersion = (poetry --version)
        #         $foundPoetryVersion -eq $desiredPoetryVersion  # emit $true if already the same
        #     }
        # }

        # uninstalling: iwr "https://install.python-poetry.org" -UseBasicParsing | python - --uninstall
        # or delete these: AppData\Roaming\pypoetry, AppData\Roaming\Python\Scripts\poetry.exe
    }
}

PythonPoetry -Output $DscMofDir\PythonPoetry -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\PythonPoetry -Wait -Force -Verbose

Get-Content $outputFile | Write-Output

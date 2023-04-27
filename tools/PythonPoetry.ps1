. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoToolsDir\PowershellConfig.ps1
. $RepoToolsDir\Pipx.ps1

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
                    $versionedPoetry = "poetry==$desiredPoetryVersion"
                } else {
                    $versionedPoetry = "poetry"
                }
                pipx install $versionedPoetry
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
    }
}

PythonPoetry -Output $DscMofDir\PythonPoetry -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\PythonPoetry -Wait -Force -Verbose

Get-Content $outputFile | Write-Output

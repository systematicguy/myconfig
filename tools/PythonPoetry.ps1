. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoToolsDir\Pipx.ps1

$desiredPoetryVersion = $UserConfig.Python.PoetryVersion

Configuration PythonPoetry
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName FileContentDsc

    Node "localhost"
    {
        Script InstallPoetry
        {
            PsDscRunAsCredential = $UserCredential
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
                # TODO expect output ending with "done!"
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

ApplyDscConfiguration "PythonPoetry" -IgnoreError # TODO don't ignore once poetry install ceases to exit with no error

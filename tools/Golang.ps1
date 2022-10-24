. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

$golangVersion = $UserConfig.Golang.Version
$golangZipFile = "go$golangVersion.windows-amd64.zip"
$goRoot = "$UserBinDir\go"
$desiredPathElement = "$goRoot\bin"

Configuration Golang
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node "localhost"
    {
        if (! (Test-Path $DscWorkDir/$golangZipFile)) {
            xRemoteFile DownloadGolang
            {
                DestinationPath = $DscWorkDir
                Uri             = "https://go.dev/dl/$golangZipFile"
            }
            $unzipDependency = "[xRemoteFile]DownloadGolang"
        } else {
            $unzipDependency = $null
        }

        Script ExtractGolang { # Archive resource would be too slow
            SetScript = {
                Expand-Archive -Force -Path "$using:DscWorkDir/$using:golangZipFile" -DestinationPath "$using:UserBinDir";
            }
            TestScript = {
                (Test-Path -Path $using:goRoot);
            }
            GetScript = {
                #Do Nothing
            }
        }

        Script GolangOnPath
        {
            DependsOn            = "[Script]ExtractGolang"
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

        Script SetUserEnvVars
        {
            # Environment resource cannot set an Environment Variable in the User's context
            Credential = $UserCredentialAtComputerDomain

            DependsOn = "[Script]ExtractGolang"

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                # https://stackoverflow.com/questions/7970390/what-should-be-the-values-of-gopath-and-goroot
                #[System.Environment]::SetEnvironmentVariable('GOPATH', "$using:goRoot", 'User')
                [System.Environment]::SetEnvironmentVariable('GOROOT', "$using:goRoot", 'User')
                [System.Environment]::SetEnvironmentVariable('GOBIN',  "$using:goRoot\bin", 'User')
            }
            TestScript = {
                $false
            }
        }
    }
}

Golang -Output $DscMofDir\Golang -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\Golang -Wait -Force -Verbose

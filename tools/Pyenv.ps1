. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\Chocolatey.ps1

$UserLocalAppData = $env:LOCALAPPDATA

$globalPythonVersion = $UserConfig.Python.GlobalVersion
$pythonInstallerFileName = "python-$globalPythonVersion-amd64.exe"
$pythonInstallerUrl = "https://www.python.org/ftp/python/$globalPythonVersion/$pythonInstallerFileName"
$cachedPythonInstallerPath = "$UserDir\.pyenv\pyenv-win\install_cache\$pythonInstallerFileName"

$pyenvOutputFile = "$DscWorkDir\pyenv.txt"
"-------------" | Out-File -Append $pyenvOutputFile -Encoding ASCII


# will modify the user's PATH environment variable
EnsureChocoPackage -Name "pyenv-win"

Configuration PyenvConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node "localhost"
    {
        # removing App Execution aliases as seen on https://superuser.com/a/1746939
        Script RemoveAppAlias 
        {
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                $localAppData = $using:UserLocalAppData
                Remove-Item $localAppData\Microsoft\WindowsApps\python.exe -ErrorAction SilentlyContinue
                Remove-Item $localAppData\Microsoft\WindowsApps\python3.exe -ErrorAction SilentlyContinue
            }
            TestScript = {
                $false
            }
        }

        if (! (Test-Path $cachedPythonInstallerPath)) {
            # This is a hack needed in some strict environments where pyenv itself was not able to download the msi file
            xRemoteFile DownloadGlobalPython
            {
                PsDscRunAsCredential = $UserCredential
                DestinationPath      = $cachedPythonInstallerPath
                Uri                  = $pythonInstallerUrl
            }
            $installGlobalPythonDependency = @("[xRemoteFile]DownloadGlobalPython")
        } else {
            $installGlobalPythonDependency = @()
        }

        Script InstallGlobalPythonVersion
        {
            DependsOn = $installGlobalPythonDependency
            Credential = $UserCredential
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                pyenv install $using:globalPythonVersion | Out-File -Append $using:pyenvOutputFile -Encoding ASCII
                if ($LASTEXITCODE -ne 0) {
                    throw "pyenv install exited with $LASTEXITCODE"
                }
                pyenv global $using:globalPythonVersion | Out-File -Append $using:pyenvOutputFile -Encoding ASCII
                if ($LASTEXITCODE -ne 0) {
                    throw "pyenv global exited with $LASTEXITCODE"
                }
            }
            TestScript = {
                (pyenv versions | Select-String $using:globalPythonVersion) -ne $null
            }
        }

        Script ShowOutput
        {
            DependsOn = "[Script]InstallGlobalPythonVersion"

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                Get-Content $using:pyenvOutputFile | Write-Verbose
            }
            TestScript = {
                !(Test-Path -Path $using:pyenvOutputFile)
            }
        }
    }
}

ApplyDscConfiguration "PyenvConfig"

# TODO remove app aliases
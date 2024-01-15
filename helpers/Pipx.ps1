. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\ToIdentifier.ps1
. $RepoRoot\helpers\UserCredential.ps1

function EnsurePipxPackage {
    param (
        [parameter(Mandatory = $true)]    
        [string]$Name,

        [parameter(Mandatory = $false)]
        [string]$Version
    )

    $dscConfigName = "pipxPackage_$(PathToIdentifier $Name)"
    Configuration $dscConfigName
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node localhost 
        {
            Script InstallPoetry
            {
                PsDscRunAsCredential = $UserCredential
                GetScript = {
                    #Do Nothing
                }
                SetScript = {
                    $packageName = $using:Name
                    $version = $using:Version
                    if ($version -ne "") {
                        $versionedPackage = "$packageName==$version"
                    } else {
                        $versionedPackage = "$packageName"
                    }
                    pipx install $versionedPackage
                    # TODO expect output ending with "done!"
                }
                TestScript = {
                    $packageName = $using:Name
                    try {
                        $foundVersionString = (& "$packageName" --version)
                    } catch {
                        $foundVersionString = $null
                    }
                    $null -ne $foundVersionString   # emit $true if already installed
                }
            }
            
        }
    }
    Write-Host "Ensuring pipx package [$Name]..."
    ApplyDscConfiguration $dscConfigName
}
. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

$CurrentUserProfilePath = $Profile.CurrentUserCurrentHost
Configuration PowershellProfile
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {        
        Script EnsureProfile
        {
            PsDscRunAsCredential = $UserCredentialAtAd

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                New-Item $using:CurrentUserProfilePath
            }
            TestScript = {
                $currentProfilepath = $using:CurrentUserProfilePath
                if (Test-Path $currentProfilepath) {
                    return $true
                } else {
                    return $false
                }
            }
        }
    }
}

PowershellProfile -Output $DscMofDir\PowershellProfile -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\PowershellProfile -Wait -Force -Verbose

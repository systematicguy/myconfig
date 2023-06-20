. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoToolsDir\PowershellProfile.ps1
. $RepoToolsDir\Chocolatey.ps1

Write-Output "Profile is $CurrentUserProfilePath"
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html
$desiredProfileContent = ". `"$RepoRoot\config\powershell_profile\aws_cli_completion.ps1`""

$AwsConfigDir = "$UserDir\.aws"
$desiredAwsConfigContent = @"
[default]
region = $($UserConfig.AwsDefaultRegion)
"@

$outputFile = "$DscWorkDir\AwsCli.txt"
Configuration AwsCli
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco
    
    Node "localhost"
    {
        cChocoPackageInstaller AwsCli
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain  # needed to be able to download the msi in some hardened corporate environments

            Name = "awscli"
        }

        cChocoPackageInstaller AwsSessionManagerPlugin
        {
            DependsOn = "[cChocoPackageInstaller]AwsCli"
            PsDscRunAsCredential = $UserCredentialAtComputerDomain  # needed to be able to download the msi in some hardened corporate environments

            Name = "awscli-session-manager"
        }

        Script EnsureProfileContent
        {
            DependsOn  = "[cChocoPackageInstaller]AwsCli"
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                Write-Output "appending to Profile [$using:CurrentUserProfilePath]" | Out-File $using:outputFile -Append
                $using:desiredProfileContent | Out-File $using:CurrentUserProfilePath -Append
            }
            TestScript = {
                Write-Output "-----------------" | Out-File $using:outputFile -Append
                Write-Output "Profile is [$using:CurrentUserProfilePath]" | Out-File $using:outputFile -Append
                $currentContent = Get-Content $using:CurrentUserProfilePath
                $desiredProfileContent = $using:desiredProfileContent
                $desiredProfileContent | Out-File $using:outputFile -Append
                if ($currentContent -eq $null) {
                    return $false
                }
                return $currentContent.ToLower().Contains($desiredProfileContent.ToLower())
            }
        }

        if (! (Test-Path "$AwsConfigDir\config")) {
            File AwsConfig
            {
                Credential      = $UserCredentialAtComputerDomain
                Type            = "File"
                DestinationPath = "$AwsConfigDir\config"
                Ensure          = "Present"
                Contents        = $desiredAwsConfigContent
            }
        }

        if (! (Test-Path "$AwsConfigDir\credentials")) {
            File AwsCredentials
            {
                Credential      = $UserCredentialAtComputerDomain
                Type            = "File"
                DestinationPath = "$AwsConfigDir\credentials"
                Ensure          = "Present"
                Contents        = ""
            }
        }
    }
}


ApplyDscConfiguration "AwsCli"

. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\Chocolatey.ps1

. $RepoToolsDir\PowershellProfile.ps1
. $RepoToolsDir\Pipx.ps1 # TODO clarify why I wanted to include this


Write-Output "Profile is $CurrentUserProfilePath"
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html
$desiredProfileContent = ". `"$RepoRoot\config\powershell_profile\aws_cli_completion.ps1`""

$AwsConfigDir = "$UserDir\.aws"
$desiredAwsConfigContent = @"
[default]
region = $($UserConfig.AwsDefaultRegion)
"@

EnsureChocoPackage -Name "awscli"
EnsureChocoPackage -Name "awscli-session-manager"
EnsureChocoPackage -Name "eksctl"

$outputFile = "$DscWorkDir\AwsCli.txt"
Configuration AwsCli
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco
    
    Node "localhost"
    {
        Script EnsureProfileContent
        {
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
                if ($null -eq $currentContent) {
                    return $false
                }
                return $currentContent.ToLower().Contains($desiredProfileContent.ToLower())
            }
        }

        if (! (Test-Path "$AwsConfigDir\config")) {
            File AwsConfig
            {
                Credential      = $UserCredential
                Type            = "File"
                DestinationPath = "$AwsConfigDir\config"
                Ensure          = "Present"
                Contents        = $desiredAwsConfigContent
            }
        }

        if (! (Test-Path "$AwsConfigDir\credentials")) {
            File AwsCredentials
            {
                Credential      = $UserCredential
                Type            = "File"
                DestinationPath = "$AwsConfigDir\credentials"
                Ensure          = "Present"
                Contents        = ""
            }
        }
    }
}
ApplyDscConfiguration "AwsCli"

. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoRoot\tools\Git.ps1
. $RepoRoot\tools\SshKey.ps1

Configuration TerraformTooling
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco

    Node "localhost"
    {
        cChocoPackageInstaller Terraform
        {
            Name    = "terraform"
            Version = $UserConfig.Terraform.Version
        }

        cChocoPackageInstaller TfLint
        {
            Name    = "tflint"
            Version = $UserConfig.Terraform.TfLintVersion
        }

        cChocoPackageInstaller TerraformDocs
        {
            Name = "terraform-docs"
        }

        Script SetUserEnvVars
        {
            # Environment resource cannot set an Environment Variable in the User's context
            Credential = $UserCredentialAtComputerDomain

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                # https://github.com/hashicorp/terraform-google-vault/issues/45#issuecomment-531903592
                [System.Environment]::SetEnvironmentVariable('GIT_SSH_COMMAND', "C:\\Windows\\System32\\OpenSSH\\ssh.exe", 'User')
            }
            TestScript = {
                $false
            }
        }
    }
}

TerraformTooling -Output $DscMofDir\TerraformTooling -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\TerraformTooling -Wait -Force -Verbose

LogTodo -Message "Get .tflint.hcl and place it into $UserDir"

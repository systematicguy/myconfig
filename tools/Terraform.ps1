. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoRoot\tools\GitConfig.ps1
. $RepoRoot\tools\SshKey.ps1

Configuration TerraformTooling
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco

    Node "localhost"
    {

        cChocoPackageInstaller Terraform
        {
            Name                 = "terraform"
            PsDscRunAsCredential = $UserCredentialAtComputerDomain  # needed to be able to download in some hardened corporate environments
            Version              = $UserConfig.Terraform.Version
        }

        cChocoPackageInstaller TfLint
        {
            Name                 = "tflint"
            PsDscRunAsCredential = $UserCredentialAtComputerDomain  # needed to be able to download in some hardened corporate environments
            Version              = $UserConfig.Terraform.TfLintVersion
        }

        cChocoPackageInstaller TerraformDocs
        {
            Name                 = "terraform-docs"
            PsDscRunAsCredential = $UserCredentialAtComputerDomain  # needed to be able to download in some hardened corporate environments
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

ApplyDscConfiguration "TerraformTooling"
LogTodo -Message "Get .tflint.hcl and place it into $UserDir"

. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\Chocolatey.ps1
. $RepoRoot\tools\GitConfig.ps1
. $RepoRoot\tools\SshKey.ps1

EnsureChocoPackage `
    -Name "terraform" `
    -Version $UserConfig.Terraform.Version

EnsureChocoPackage `
    -Name "tflint" `
    -Version $UserConfig.Terraform.TfLintVersion

EnsureChocoPackage `
    -Name "terraform-docs"

Configuration TerraformTooling
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Script SetUserEnvVars
        {
            # Environment resource cannot set an Environment Variable in the User's context
            Credential = $UserCredential

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

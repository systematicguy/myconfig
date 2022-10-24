. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

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
    }
}

TerraformTooling -Output $DscMofDir\TerraformTooling -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\TerraformTooling -Wait -Force -Verbose

LogTodo -Message "Get .tflint.hcl and place it into $UserDir"

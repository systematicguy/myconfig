. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoToolsDir\Pipx.ps1
. $RepoToolsDir\GitConfig.ps1
. $RepoToolsDir\Terraform.ps1  # TODO reconsider this dependency in light of potential for modular precommit config

$GitTemplateDir = "$HOME/.git-template"

Configuration PreCommit
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName FileContentDsc

    Node "localhost"
    {
        Script InstallPrecommit
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                Invoke-Command { $env:PIP_REQUIRE_VIRTUALENV = 0; pipx install pre-commit }
            }
            TestScript = {
                $false
            }
        }

        # TODO: merge settings instead of overwriting them
        File PreCommitConfig
        {
            Type            = 'File'
            SourcePath      = "$RepoRoot\config\precommit\.pre-commit-config.yaml"
            DestinationPath = "$UserDir\.pre-commit\.pre-commit-config.yaml"
            Ensure          = "Present"
            Checksum        = "SHA-1"
        }

        Script ConfigurePrecommitTemplate
        {
            DependsOn = @("[Script]InstallPrecommit", "[File]PreCommitConfig")
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                $gitTemplateDir = $using:GitTemplateDir
                git config --global init.templateDir $gitTemplateDir
                pre-commit init-templatedir --config $HOME/.pre-commit/.pre-commit-config.yaml $gitTemplateDir
            }
            TestScript = {
                Test-Path $using:GitTemplateDir/hooks/pre-commit
            }
        }
    }
}

ApplyDscConfiguration "PreCommit"

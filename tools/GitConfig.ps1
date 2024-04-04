. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\Chocolatey.ps1
. $RepoToolsDir\LongPathsEnabled.ps1

EnsureChocoPackage -Name "git" # untested, was without credentials

Configuration GitConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Script GitConfig 
        {
            Credential = $UserCredential

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                ###############
                # system config

                # use Windows' builtin networking layer as ssl backend
                #  https://stackoverflow.com/questions/16668508/how-do-i-configure-git-to-trust-certificates-from-the-windows-certificate-store/48212753
                git config --system http.sslbackend schannel

                git config --system credential.helper manager-core
                git config --system core.fscache true
                git config --system core.longpaths true
                
                ################################
                # global config (os-independent)
                git config --global user.name $using:UserConfig.Git.UserName
                git config --global user.email $using:UserConfig.Git.UserEmail

                git config --global core.autocrlf input
                git config --global core.symlinks true

                git config --global submodule.recurse true

                if ($LASTEXITCODE -ne 0) {
                    throw "Exited with $LASTEXITCODE"
                }
            }
            TestScript = {
                $false
            }
        }
    }
}
ApplyDscConfiguration "GitConfig"
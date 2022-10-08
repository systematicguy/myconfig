if ($_AlreadySourcedGitConfig -ne $null) { return } else { $_AlreadySourcedGitConfig = $true }

. $PSScriptRoot\..\..\windows\Environment.ps1
. $RepoRoot\machine\corp\GitConfig.ps1

$sshKeyFilePath = "$UserDir\.ssh\id_$($UserConfig.SshKeygen.Algorithm)"
Write-Output "Checking existence of $sshKeyFilePath..."
$outputFile = "$DscWorkDir\ssh_key.txt"
if (! (Test-Path $sshKeyFilePath)) {
    . $PSScriptRoot\..\..\windows\UserCredential.ps1

    $sshKeyPasswordCredential = Get-Credential -Message "Specify password for ssh key" -User "n.a."

    Configuration SshKey
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node "localhost"
        {
            File SshDir 
            {
                Credential      = $UserCredential
                Type            = "Directory"
                DestinationPath = "$UserDir\.ssh"
                Ensure          = "Present"
            }

            Script SshKey
            {
                DependsOn = "[File]SshDir"
                Credential = $UserCredential

                GetScript = {
                    #Do Nothing
                }
                SetScript = {
                    $sshPwCred = $using:sshKeyPasswordCredential
                    $sshKeyPassword = $sshPwCred.GetNetworkCredential().Password

                    ssh-keygen `
                        -t $using:UserConfig.SshKeygen.Algorithm `
                        -C $using:UserConfig.Git.UserEmail `
                        -f $using:sshKeyFilePath `
                        -N $sshKeyPassword

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

    SshKey -Output $DscMofDir\SshKey -ConfigurationData $DscConfigPath
    Start-DscConfiguration -Path $DscMofDir\SshKey -Wait -Force -Verbose

    LogTodo -Message "Don't forget to add your public ssh key to BitBucket, Github, Gitlab, etc."
}

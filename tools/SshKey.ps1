. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $PSScriptRoot\..\windows\CredentialProvider.ps1

$sshKeyFilePath = "$UserDir\.ssh\id_$($UserConfig.SshKey.Type)"
Write-Output "Checking existence of $sshKeyFilePath..."
$outputFile = "$DscWorkDir\ssh_key.txt"
if (! (Test-Path $sshKeyFilePath)) {
    . $RepoRoot\windows\UserCredential.ps1

    $sshKeyPasswordCredential = ProvideCredential -Purpose "ssh_key_passphrase" -Message "Specify password for ssh key" -User "n.a."

    Configuration SshKey
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node "localhost"
        {
            File SshDir 
            {
                Credential      = $UserCredentialAtComputerDomain
                Type            = "Directory"
                DestinationPath = "$UserDir\.ssh"
                Ensure          = "Present"
            }

            Script SshKeygen
            {
                DependsOn = "[File]SshDir"
                Credential = $UserCredentialAtComputerDomain

                GetScript = {
                    #Do Nothing
                }
                SetScript = {
                    $sshPwCred = $using:sshKeyPasswordCredential
                    $sshKeyPassword = $sshPwCred.GetNetworkCredential().Password

                    ssh-keygen `
                        -t $using:UserConfig.SshKey.Type `
                        -C $using:UserConfig.SshKey.Comment `
                        -f $using:sshKeyFilePath `
                        -N $sshKeyPassword | Out-File $using:outputFile

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

    ApplyDscConfiguration "SshKey"
    LogTodo -Message "Don't forget to add your public ssh key to BitBucket, Github, Gitlab, etc."
}

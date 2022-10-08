if ($_AlreadySourcedGitConfig -ne $null) { return } else { $_AlreadySourcedGitConfig = $true }

. $PSScriptRoot\..\..\windows\Environment.ps1
. $RepoRoot\machine\corp\GitConfig.ps1

$sshKeyFilePath = "$UserDir\.ssh\id_$($UserConfig.SshKeygen.Algorithm)"
Write-Output "Checking existence of $sshKeyFilePath..."
$outputFile = "$DscWorkDir\ssh_key.txt"
if (! (Test-Path $sshKeyFilePath)) {
    . $PSScriptRoot\..\..\windows\UserCredential.ps1

    # $sshKeyPassword = Read-Host -AsSecureString "Specify password for ssh key"
    $sshKeyPasswordCredential = Get-Credential -Message "Specify password for ssh key" -User "n.a."

    configuration SshKey
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node "localhost"
        {
            Script SshKey
            {
                Credential = $UserCredential

                GetScript = {
                    #Do Nothing
                }
                SetScript = {
                    $sshPwCred = $using:sshKeyPasswordCredential
                    $sshKeyPassword = $sshPwCred.GetNetworkCredential().Password

                    ssh-keygen -N $sshKeyPassword -t $using:UserConfig.SshKeygen.Algorithm -C $using:UserConfig.Git.UserEmail -f $using:sshKeyFilePath

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
}
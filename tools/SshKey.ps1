. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\CredentialProvider.ps1

$outputFile = "$DscWorkDir\ssh_key.txt"
Write-Output "-----------------------------------" | Out-File $outputFile -Append

Configuration SshDir
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
    }
}
ApplyDscConfiguration "SshDir"

foreach ($sshKeyName in $UserConfig.SshKey.GeneratedKeys.Keys) {
    $sshKeyConfig = $UserConfig.SshKey.GeneratedKeys[$sshKeyName]
    $sshKeyFilePath = "$UserDir\.ssh\id_$($sshKeyName)"
    Write-Output "Checking existence of $sshKeyFilePath..."
    if (Test-Path $sshKeyFilePath) {
        Write-Output "Skipping $sshKeyFilePath because it already exists."
        continue
    }
    . $RepoRoot\helpers\UserCredential.ps1

    $sshKeyPasswordCredential = ProvideCredential -Purpose "ssh_key_passphrase_$sshKeyName" -Message "Specify password for ssh key $sshKeyName" -User "n.a."

    $sshKeyConfigName = "SshKey_$sshKeyName"
    Configuration $sshKeyConfigName
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node "localhost"
        {
            Script SshKeygen
            {
                Credential = $UserCredential

                GetScript = {
                    #Do Nothing
                }
                TestScript = {
                    $false
                }
                SetScript = {
                    $sshPwCred = $using:sshKeyPasswordCredential
                    $sshKeyPassword = $sshPwCred.GetNetworkCredential().Password

                    ssh-keygen `
                        -t $using:sshKeyConfig.Type `
                        -C $using:sshKeyConfig.Comment `
                        -f $using:sshKeyFilePath `
                        -N $sshKeyPassword | Out-File $using:outputFile -Append

                    if ($LASTEXITCODE -ne 0) {
                        throw "Exited with $LASTEXITCODE"
                    }
                }
            }
        }
    }

    ApplyDscConfiguration $sshKeyConfigName
    LogTodo -Message "Don't forget to add your public ssh key for $sshKeyName to: $($sshKeyConfig.ReminderPurposes)"
}
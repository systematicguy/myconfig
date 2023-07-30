. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1

$SshKnownHostsFile = "$UserDir\.ssh\known_hosts"

if (! (Test-Path $SshKnownHostsFile)) {
    Configuration SshKnownHosts
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node "localhost"
        {
            File SshKnownHosts
            {
                Credential      = $UserCredential
                Type            = "File"
                DestinationPath = $SshKnownHostsFile
                Ensure          = "Present"
                Contents        = ""
            }
        }
    }

    ApplyDscConfiguration "SshKnownHosts"
}


Configuration SshKeyScan
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        foreach ($hostName in $UserConfig.SshKey.KeyScannedHosts)
        {
            Script "SshKeyScan_$hostName"
            {
                Credential = $UserCredential

                GetScript = {
                    #Do Nothing
                }
                SetScript = {
                    $hostKey = (ssh-keyscan -p 7999 $using:hostName 2> $null)
                    if ($LASTEXITCODE -ne 0) {
                        throw "Exited with $LASTEXITCODE"
                    }

                    $knownHostsContent = Get-Content $using:SshKnownHostsFile
                    if ($knownHostsContent -eq $null) {
                        $knownHostsContent = ""
                    }
                    if (! $knownHostsContent.Contains($hostKey)) {
                        $hostKey | Out-File $using:SshKnownHostsFile -Encoding ASCII -Append
                    }
                }
                TestScript = {
                    $false
                }
            }
        }
    }
}

ApplyDscConfiguration "SshKeyScan"

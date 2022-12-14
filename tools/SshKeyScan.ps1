. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

$SshKnownHostsFile = "$UserDir\.ssh\known_hosts"

if (! (Test-Path $SshKnownHostsFile)) {
    Configuration SshKnownHosts
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node "localhost"
        {
            File SshKnownHosts
            {
                Credential      = $UserCredentialAtComputerDomain
                Type            = "File"
                DestinationPath = $SshKnownHostsFile
                Ensure          = "Present"
                Contents        = ""
            }
        }
    }

    SshKnownHosts -Output $DscMofDir\SshKnownHosts -ConfigurationData $DscConfigPath
    Start-DscConfiguration -Path $DscMofDir\SshKnownHosts -Wait -Force -Verbose
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
                Credential = $UserCredentialAtComputerDomain

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

SshKeyScan -Output $DscMofDir\SshKeyScan -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\SshKeyScan -Wait -Force -Verbose

. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\CredentialProvider.ps1
. $RepoRoot\helpers\Registry.ps1
Import-Module CredentialManager

$outputFile = "$DscWorkDir\map_network_drives.txt"
Write-Output "-----------------" | Out-File $outputFile -Append

# https://4ddig.tenorshare.com/windows-fix/how-to-fix-network-drive-not-showing.html
EnsureRegistry -Purpose "NetworkMapping" -RegistryConfig @{
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" = @{
        EnableLinkedConnections = 0x00000001  # Enable linked connections
    }
}

# persist credentials for network drives in windows credential manager
$credentialGroups = $UserConfig.NetworkDriveConfig.CredentialGroups
$collectedCredentials = @{}
foreach($credentialGroupName in $credentialGroups.Keys) {
    Write-Host "Dealing with password for network drive group [$credentialGroupName]..."
    $credentialGroup = $CredentialGroups[$credentialGroupName]
    $networkDriveCredentials = Get-StoredCredential -Target $credentialGroup.NetworkAddress
    if ($null -eq $networkDriveCredentials) {
        $networkDriveCredentials = ProvideCredential `
            -Purpose $credentialGroupName `
            -Message "Specify credentials for network drive group [$credentialGroupName] to [$($credentialGroup.NetworkAddress)]" `
            -UserName $credentialGroup.UserName 
        Write-Host "Storing Windows Credentials for target [$($credentialGroup.NetworkAddress)]..."
        New-StoredCredential -Credentials $networkDriveCredentials -Type DomainPassword -Target $credentialGroup.NetworkAddress -Persist "Enterprise" > $null
    } else {
        Write-Host "Credentials already stored in credential store for target [$($credentialGroup.NetworkAddress)]"
    }
    $collectedCredentials[$credentialGroupName] = $networkDriveCredentials
}

Configuration MapNetworkDrives
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Script MapNetworkDrives
        {
            Credential = $UserCredential

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                $collectedCredentials = $using:collectedCredentials
                $outputFile = $using:outputFile
                $UserConfig = $using:UserConfig
                foreach ($driveLetter in $UserConfig.NetworkDriveConfig.Drives.Keys) {
                    $drive = $UserConfig.NetworkDriveConfig.Drives[$driveLetter]
                    if (Get-PSDrive -Name $driveLetter -ErrorAction SilentlyContinue) {
                        Write-Output "Network drive [$driveLetter] is already mounted." | Out-File $outputFile -Append
                        continue
                    }
                
                    $path = $drive.Path
                    $credentialGroupName = $drive.credentialGroup
                    if ($null -ne $credentialGroupName) {
                        Write-Output "Creating network drive [$driveLetter] to [$path] using credential [$credentialGroupName]" | Out-File $outputFile -Append
                        New-PSDrive -Name $driveLetter -PSProvider FileSystem -Root $path -Scope "Global" -Persist -Credential $collectedCredentials[$credentialGroupName] | Out-File $outputFile -Append
                    } else {
                        Write-Output "Creating network drive [$driveLetter] to [$path]" | Out-File $outputFile -Append
                        New-PSDrive -Name $driveLetter -PSProvider FileSystem -Root $path -Scope "Global" -Persist | Out-File $outputFile -Append
                    }
                }   
            }
            TestScript = {
                $false
            }
        }
    }
}
ApplyDscConfiguration "MapNetworkDrives"

LogTodo -Message "You might need to restart Explorer.exe to see the network drives in Windows Explorer. you can use scripts\restartExplorer.ps1"
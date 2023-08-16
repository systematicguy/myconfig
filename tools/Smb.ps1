. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

Configuration SmbDirectFeature
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node "localhost" 
    {
        xWindowsOptionalFeatureSet SmbDirectFeature
        {
            Name = (
                "SMBDirect"  # needed form Samba 3.x
            )
            NoWindowsUpdateCheck = $true
            Ensure               = "Present"
        }
    }
}
ApplyDscConfiguration "SmbDirectFeature"

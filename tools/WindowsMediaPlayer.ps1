. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

Configuration WindowsMediaPlayerFeature
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node "localhost" 
    {
        xWindowsOptionalFeatureSet WindowsMediaPlayerFeature
        {
            Name = (
                "WindowsMediaPlayer"
            )
            NoWindowsUpdateCheck = $true
            Ensure               = "Present"
        }
    }
}
ApplyDscConfiguration "WindowsMediaPlayerFeature"

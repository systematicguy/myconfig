. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\Get-DscSplattedResource.ps1

Configuration Chocolatey
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco

    Node "localhost"
    {
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\ProgramData\chocolatey"
        }
    }
}
ApplyDscConfiguration "Chocolatey"

function EnsureChocoPackage {
    param(
        [parameter(Mandatory = $true)]    
        [string]$Name,

        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Version,

        [parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Params,

        [parameter(Mandatory = $false)]
        [PsCredential]$Credential = $null
    )
    
    if ($null -eq $Credential) {
        $Credential = $UserCredential
    }

    $configurationName = "ChocoPackage_$Name"

    $configObject = @{
        PsDscRunAsCredential = $Credential
        Name                 = $Name
    }
    if ($PSBoundParameters.ContainsKey('Version') -and $null -ne $Version) {
        $configObject.Version = $Version
    }
    if ($PSBoundParameters.ContainsKey('Params') -and $null -ne $Params) {
        $configObject.Params = $Params
    }

    Configuration $configurationName
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName cChoco

        Node "localhost"
        {
            Get-DscSplattedResource cChocoPackageInstaller "Choco_$Name" -Properties $configObject
        }
    }
    ApplyDscConfiguration $configurationName
}
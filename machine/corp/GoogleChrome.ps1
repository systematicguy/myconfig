$ErrorActionPreference = "Stop"

$dscConfigPath = ".\DscConfig.psd1"

# TODO move to separate module:
if ($myCreds -eq $null) {
    Write-Output "Retrieving domain..."
    $domain = (systeminfo | findstr /B /C:"Domain") | Out-String
    $myCreds = Get-Credential -Message "Specify credentials like user@domain. $domain"
} else {
    Write-Output "Working with existing credentials for $($myCreds.UserName)"
}

configuration GoogleChrome
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco 

    Node "localhost"
    {
        cChocoPackageInstaller GoogleChrome
        {
            Name = "googlechrome"
            # This package uses Chrome's administrative MSI installer and installs the 32-bit on 32-bit OSes and the 64-bit version on 64-bit OSes. 
            # If this package is installed on a 64-bit OS and the 32-bit version of Chrome is already installed, the package keeps installing/updating the 32-bit version of Chrome.
        }
        

        cChocoPackageInstaller SetDefaultBrowser
        {
            Name = "setdefaultbrowser"
            # https://kolbi.cz/blog/2017/11/10/setdefaultbrowser-set-the-default-browser-per-user-on-windows-10-and-server-2016-build-1607/
        }
    }
}

configuration GoogleChromeAsDefaultBrowser
{
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $UserCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Script SetAsDefaultBrowser {
            Credential = $UserCredential

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                Write-Verbose "$env:UserName"
                $env:UserName | Out-File "$env:UserProfile\username.txt" -Encoding ASCII
                SetDefaultBrowser chrome
                # https://kolbi.cz/blog/2017/11/10/setdefaultbrowser-set-the-default-browser-per-user-on-windows-10-and-server-2016-build-1607/
            }
            TestScript = {
                $false
            }
        }   
    }
}


# Compile the configuration file to a MOF format
GoogleChrome 
GoogleChromeAsDefaultBrowser -UserCredential $myCreds -ConfigurationData $dscConfigPath

Start-DscConfiguration -Path .\GoogleChrome -Wait -Force -Verbose
Start-DscConfiguration -Path .\GoogleChromeAsDefaultBrowser -Wait -Force -Verbose

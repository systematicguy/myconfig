. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoToolsDir\Chocolatey.ps1
. $RepoRoot\helpers\UserCredential.ps1

Configuration GoogleChrome
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco
    Import-DscResource -Name cChocoPackageInstaller -ModuleName cChoco

    Node "localhost"
    {
        cChocoPackageInstaller GoogleChrome
        {
            PsDscRunAsCredential = $UserCredential  # needed to be able to download the msi in some hardened corporate environments
            Name                 = "googlechrome"
            # This package uses Chrome's administrative MSI installer and installs the 32-bit on 32-bit OSes and the 64-bit version on 64-bit OSes.
            # If this package is installed on a 64-bit OS and the 32-bit version of Chrome is already installed, the package keeps installing/updating the 32-bit version of Chrome.
        }


        cChocoPackageInstaller SetDefaultBrowser
        {
            PsDscRunAsCredential = $UserCredential  # untested, was wo credentials

            Name = "setdefaultbrowser"
            # https://kolbi.cz/blog/2017/11/10/setdefaultbrowser-set-the-default-browser-per-user-on-windows-10-and-server-2016-build-1607/
        }
    }
}


$outputFile = "$DscWorkDir\GoogleChromeAsDefaultBrowser.txt"

Configuration GoogleChromeAsDefaultBrowser
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost"
    {
        Script SetAsDefaultBrowser
        {
            Credential = $UserCredential

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                SetDefaultBrowser chrome | Out-File $using:outputFile -Encoding ASCII
                # https://kolbi.cz/blog/2017/11/10/setdefaultbrowser-set-the-default-browser-per-user-on-windows-10-and-server-2016-build-1607/
                if ($LASTEXITCODE -ne 0) {
                    throw "Exited with $LASTEXITCODE"
                }
            }
            TestScript = {
                $false
            }
        }

        Script ShowOutput
        {
            DependsOn = "[Script]SetAsDefaultBrowser"

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                Get-Content $using:outputFile | Write-Verbose
            }
            TestScript = {
                !(Test-Path -Path $using:outputFile)
            }
        }
    }
}

ApplyDscConfiguration "GoogleChrome"
ApplyDscConfiguration "GoogleChromeAsDefaultBrowser"
. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoToolsDir\Chocolatey.ps1

Configuration VsCode
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName cChoco

    Node "localhost"
    {
        cChocoPackageInstaller InstallVsCode
        {
            Name = "vscode"

            # TODO: auto-theme switch
            # TODO: plugins
        }
    }
}

VsCode -Output $DscMofDir\VsCode
Start-DscConfiguration -Path $DscMofDir\VsCode -Wait -Force -Verbose

$VsCodeExePath = "C:\Program Files\Microsoft VS Code\Code.exe"
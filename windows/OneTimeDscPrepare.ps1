. $PSScriptRoot\Environment.ps1

[cultureinfo]::CurrentUICulture = 'en-US'
Set-WinSystemLocale en-US

# was needed on my own laptop, some corporate machines have it already:
try {
    Set-WSManQuickConfig -Force
} catch {
    Write-Host "You can probably ignore this error. Most machines need Set-WSManQuickConfig."
    Write-Host "In some corporate setup it is not needed any more, but you never know beforehand and those in turn might fail if you try to perform this."
}

# maybe needed:
#Install-Module -Name PSDscResources -Force

Write-Output "Installing required Powershell Modules and Scripts..."
Install-Module -Name cChoco -Force
Install-Module -Name FileContentDsc -Force
Install-Module -Name xPSDesiredStateConfiguration -Force
Install-Module -Name ComputerManagementDsc -Force
Install-Module -Name PowerShellModule -Force
Install-Module -Name xPowerShellExecutionPolicy -Force
Install-Module -Name DSCR_AppxPackage -Force
Install-Module -Name CredentialManager -Force
Install-Script -Name ConvertTo-Expression -Force

. $PSScriptRoot\DscSetupCert.ps1

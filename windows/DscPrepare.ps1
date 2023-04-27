. $PSScriptRoot\Environment.ps1

[cultureinfo]::CurrentUICulture = 'en-US'
Set-WinSystemLocale en-US

# maybe needed:
#Set-WsManQuickConfig -Force

# maybe needed:
#Install-Module -Name PSDscResources -Force

Write-Output "Installing required Powershell Modules and Scripts..."
Install-Module -Name cChoco -Force
Install-Module -Name FileContentDsc -Force
Install-Module -Name xPSDesiredStateConfiguration -Force
Install-Module -Name ComputerManagementDsc -Force
Install-Module -Name PowerShellModule -Force
Install-Module -Name xPowerShellExecutionPolicy -Force
Install-Script -Name ConvertTo-Expression -Force

. $PSScriptRoot\DscSetupCert.ps1

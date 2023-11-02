#if you have downloaded this as a zip from github, you need to unblock the whole folder:
# Get-ChildItem -Path . -Recurse | Unblock-File
#alternatively you can bypass the execution policy for this process:
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

. $PSScriptRoot\Environment.ps1

# for local admin accounts to be able to use WSMan service we need to disable UAC:
# https://softwarealliance.freshdesk.com/support/solutions/articles/22000243674-the-wsman-service-could-not-load-host-process-error
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1 -Type DWord

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
Install-Module -Name powershell-yaml -Force
Install-Module -Name PendingReboot -Force
Install-Script -Name ConvertTo-Expression -Force

. $PSScriptRoot\DscSetupCert.ps1

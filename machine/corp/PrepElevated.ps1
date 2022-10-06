[cultureinfo]::CurrentUICulture = 'en-US'
Set-WinSystemLocale en-US

# maybe needed:
#Set-WsManQuickConfig -Force

# maybe needed:
#Install-Module -Name PSDscResources -Force

Install-Module -Name ConvertTo-Expression -Force

Install-Module -Name cChoco -Force

Install-Module -Name FileContentDsc -Force

choco install yq -y
Install-Module -Name PSYamlQuery -Force

.\DscSetupCert.ps1
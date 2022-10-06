# maybe needed:
# Set-WsManQuickConfig -Force

Install-Module -Name cChoco -Force

Install-Module -Name FileContentDsc -Force

choco install yq -y
Install-Module -Name PSYamlQuery -Force
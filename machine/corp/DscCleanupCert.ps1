. $PSScriptRoot\Environment.ps1

Get-ChildItem -Path Cert:\LocalMachine\My | 
    Where-Object {$_.Subject -like "*=DscEncryptionCert"} | 
    ForEach-Object {Remove-Item -Path "Cert:\LocalMachine\My\$($_.Thumbprint)" -Recurse -Verbose}

Remove-Item $LocalConfig.PublicKeyPath
Remove-Item $LocalConfig.DscConfigPath
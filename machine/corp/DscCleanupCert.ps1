Get-ChildItem -Path Cert:\LocalMachine\My | 
    Where-Object {$_.Subject -like "*=DscEncryptionCert"} | 
    ForEach-Object {Remove-Item -Path "Cert:\LocalMachine\My\$($_.Thumbprint)" -Recurse -Verbose}

Remove-Item ".\DscConfig.psd1"
Remove-Item ".\DscPublicKey.cer"
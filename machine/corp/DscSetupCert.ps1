. $PSScriptRoot\Environment.ps1

Write-Output "Configuring self-signed certificates for LCM..."

# generating a cert for encryption of MOF files (some of them will contain credentials)
# as seen on https://learn.microsoft.com/en-us/powershell/dsc/pull-server/secureMOF?view=dsc-1.1

$publicKeyPath = $LocalConfig.PublicKeyPath
$dscConfigPath = $LocalConfig.DscConfigPath

# https://learn.microsoft.com/en-us/powershell/dsc/pull-server/secureMOF?view=dsc-1.1#creating-the-certificate-on-the-target-node
# Note: These steps need to be performed in an Administrator PowerShell session on the target node.
# Yes, the target node is the same as the authoring node, but for clarity, we refer to this as if it were remote.
# New-SelfSignedCertificate will store the cert in the default store (-CertStoreLocation) which is Cert:\LocalMachine\My 
#  because we are running as Administrator.
#  https://learn.microsoft.com/en-us/powershell/module/pki/new-selfsignedcertificate?view=windowsserver2022-ps#-certstorelocation
$cert = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName 'DscEncryptionCert' -HashAlgorithm SHA256

# export the public key certificate for sake of the authoring node
$cert | Export-Certificate -FilePath $publicKeyPath -Force
$publicKeyPath = (Resolve-Path $publicKeyPath).Path

# The following can be skipped because the target node is the same as the authoring node 
#  and New-SelfSignedCertificate already imports the cert.
# However, if the target node would be remote, we would import the public cert to the my store of the authoring node:
# Import-Certificate -FilePath $publicKeyPath -CertStoreLocation Cert:\LocalMachine\My


# we need to configure the target node so it knows which cert's private key to use for decryption. It allegedly finds it via the thumbprint.
# https://learn.microsoft.com/en-us/powershell/dsc/managing-nodes/metaconfig?view=dsc-1.1
[DSCLocalConfigurationManager()]
Configuration LCMConfig 
{
    Node "localhost"
    {
        Settings
        {
            CertificateID = $cert.Thumbprint
        }
    }
}
LCMConfig -Output $DscMofDir\LCMConfig
Set-DscLocalConfigurationManager -Path $DscMofDir\LCMConfig -Force -Verbose

# this is the configdata to be used on the author node if credentials need to be passed
$ConfigData = @{
    AllNodes = @(
        @{
            NodeName             = "localhost"
            
            # https://learn.microsoft.com/en-us/powershell/dsc/configurations/configdatacredentials?view=dsc-1.1
            PSDSCAllowDomainUser = $true
            
            # The path to the .cer file containing the public key of the Encryption Certificate
            #  used to encrypt credentials for this target node
            CertificateFile     = $publicKeyPath

            # The thumbprint of the Encryption Certificate used to decrypt the credentials on target node.
            Thumbprint          = $cert.Thumbprint
        }
    )
}

# https://stackoverflow.com/questions/60621582/does-powershell-support-hashtable-serialization
# https://www.powershellgallery.com/packages/ConvertTo-Expression/3.3.9
# Persist the config to a psd1 file. to be used during MOF generation passed like this: 
#  -ConfigurationData $dscConfigPath
$ConfigData | ConvertTo-Expression | Out-File $dscConfigPath
# How to create a self sign cert and use it to sign Machine Configuration
# custom policy package

# Create Code signing cert
$codeSigningParams = @{
    Type          = 'CodeSigningCert'
    DnsName       = 'GCEncryptionCertificate'
    HashAlgorithm = 'SHA256'
}
$certificate = New-SelfSignedCertificate @codeSigningParams

# Export the certificates
$privateKey = @{
    Cert     = $certificate
    Password = Read-Host "Enter password for private key" -AsSecureString
    FilePath = '<full-path-to-export-private-key-pfx-file>'
}
$publicKey = @{
    Cert     = $certificate
    FilePath = '<full-path-to-export-public-key-cer-file>'
    Force    = $true
}
Export-PfxCertificate @privateKey
Export-Certificate    @publicKey

# Import the certificate
$importParams = @{
    FilePath          = $privateKey.FilePath
    Password          = $privateKey.Password
    CertStoreLocation = 'Cert:\LocalMachine\My'
}
Import-PfxCertificate @importParams

# Sign the policy package
$certToSignThePackage = Get-ChildItem -Path Cert:\LocalMachine\My |
    Where-Object { $_.Subject -eq "CN=GCEncryptionCertificate" }
$protectParams = @{
    Path        = '<path-to-package-to-sign>'
    Certificate = $certToSignThePackage
    Verbose     = $true
}
Protect-GuestConfigurationPackage @protectParams
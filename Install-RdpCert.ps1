#Requires -RunAsAdministrator
param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

# Import certificate

$pfx = Get-PfxData -FilePath $Path
$pfx = $pfx.EndEntityCertificates[0]
$certs = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $pfx.Thumbprint }

if ($certs.Count -eq 0) {
    Write-Host 'pfx file not in store, installing'
    Import-PfxCertificate -FilePath $Path -CertStoreLocation Cert:\LocalMachine\My
    
    $certs = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $pfx.Thumbprint }
    $cert = $certs[0]
}
else {
    Write-Host 'pfx file already in store'
    $cert = $certs[0]
}

# Grant NETWORK SERVICE access to certificate private key

$rsaCert = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
$fileName = $rsaCert.key.UniqueName
$path = "$env:ALLUSERSPROFILE\Microsoft\Crypto\Keys\$fileName"
$permissions = Get-Acl -Path $path

$networkService = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::NetworkServiceSid, $null)
$rules = $permissions.Access | Where-Object { $_.IdentityReference.Translate($networkService.GetType()).Value -eq $networkService.Value }

if ($rules.Count -eq 0) {
    Write-Host 'network service does not have access, adding'
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($networkService, 'Read', 'None', 'None', 'Allow')
    $permissions.AddAccessRule($rule)
    Set-Acl -Path $path -AclObject $permissions
}
else {
    Write-Host 'network service already has access'
}

# Write registry

$thumb = $cert.Thumbprint -split '(\w{2})' | Where-Object { $_ } | ForEach-Object { "0x$_" }
Write-Host $thumb
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'SSLCertificateSHA1Hash' -PropertyType Binary -Value ([byte[]] $thumb) -Force
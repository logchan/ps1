# Prepare a certificate for importing to android system certs

param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [Parameter]
    [string]$OpenSSL
)

$s = (&$OpenSSL x509 -inform DER -subject_hash_old -in $Path 2>$null)
$s = $s[0]
$name = "$s.0"
Write-Host $name
$fi = New-Object "System.IO.FileInfo" -ArgumentList $Path
$newName = "$($fi.Directory.FullName)\$name"
Write-Host $newName
$s = (&$OpenSSL x509 -inform DER -in $Path 2>$null)
[System.IO.File]::WriteAllLines($newName, $s)
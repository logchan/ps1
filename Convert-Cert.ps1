# Convert a certificate file to PFX
# Private key is included if it has the same base name and ".key" extension

param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

certutil -MergePFX $Path "$($Path.Substring(0, $Path.LastIndexOf('.'))).pfx"
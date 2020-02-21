# Create an RamDisk with folders and permission
# Requires imdisk to be installed: http://www.ltr-data.se/opencode.html/

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $DriveLetter = 'R',
    [Parameter()]
    [int]
    $Size = 8,
    [Parameter()]
    [string[]]
    $Folders = @('Temp', 'Share')
)

$root = "$($DriveLetter):\"

if (-not [System.IO.Directory]::Exists($root)) {
    Write-Host "Create RamDisk partition"
    imdisk -a -t vm -m "$($DriveLetter):" -s "$($Size)G" -p "/fs:ntfs /q /y"
}
else {
    Write-Host "RamDisk partition exists"
}

$acl = Get-Acl $root
$everyone = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::WorldSid, $null)
$access = $acl.Access | Where-Object { $_.IdentityReference.Translate($everyone.GetType()).Value -eq $everyone.Value }

if ($access.Count -eq 0) {
    Write-Host "Give Everyone access"
    $flags = [System.Security.AccessControl.FileSystemRights]::Modify
    $flags += [System.Security.AccessControl.FileSystemRights]::Synchronize

    $inherit = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
    $inherit += [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    $access = New-Object System.Security.AccessControl.FileSystemAccessRule($everyone, $flags, $inherit, 'None', 'Allow')

    $acl.AddAccessRule($access)
    Set-Acl $root $acl
}
else {
    Write-Host "Everyone already has access"
}

foreach ($folder in $Folders) {
    $path = [System.IO.Path]::Combine($root, $folder)
    if ([System.IO.Directory]::Exists($path)) {
        continue
    }

    Write-Host "Create $path"
    [System.IO.Directory]::CreateDirectory($path) | Out-Null
}
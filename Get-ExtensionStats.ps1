# Count the number of file extensions in a directory

param (
    [string] $Dir = ""
)

$dict = @{}
foreach ($f in Get-ChildItem -Path $Dir -Recurse -File) {
    $ext = $f.Extension
    if (-not ($dict.ContainsKey($ext))) {
        $dict.Add($ext, 0)
    }
    $dict[$ext] = $dict[$ext] + 1
}

$keys = $dict.Keys | Sort-Object
foreach ($key in $keys) {
    Write-Host "$key`t$($dict[$key])"
}
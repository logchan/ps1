# Rename 1.jpg, 2.jpg, ..., 123.jpg to 001.jpg, 002.jpg, ..., 123.jpg

param (
    [switch] $skipValidation = $false
)

$sources = @()
$max = 0
$r = [regex] '^([^\d]*)(\d+)([^\d]*)\..+$'
foreach ($f in Get-ChildItem) {
    $m = $r.Match($f.Name)
    if ($m.Success) {
        $sources += $f
        $max = [System.Math]::Max($max, [int] $m.Groups[2].Value)
    }
}

$max = [System.Math]::Max($max, 1)
$formatter = '0'
foreach ($i in 1..[int][System.Math]::Floor([System.Math]::Log10($max))) {
    $formatter += '0'
}

Write-Host "Max is $max, formatter is $formatter"

$formatter = "{0:$formatter}"
$tasks = @()
foreach ($f in $sources) {
    $m = $r.Match($f.Name)
    $num = [int] $m.Groups[2].Value
    
    $formatted = [System.String]::Format($formatter, $num)
    $g = "$($m.Groups[1].Value)$($formatted)$($m.Groups[3].Value)$($f.Extension)"
    $task = [PSCustomObject]@{
        File = $f;
        NewName = $g
    }
    $tasks += $task
}

$tasks = $tasks | Sort-Object -Property NewName
foreach ($t in $tasks) {
    Write-Host "$($t.File.Name) -> $($t.NewName)"
}

if (-not $skipValidation) {
    $response = Read-Host 'Execute (y/N)'
    if ($response -ne 'y') {
        exit
    }
}

foreach ($t in $tasks) {
    $t.File.MoveTo([System.IO.Path]::Combine($t.File.Directory.FullName, $t.NewName))
}

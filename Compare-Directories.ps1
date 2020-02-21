# Compare files in two directories

param (
    [Parameter(Mandatory=$true)]
    [string] $Left,
    [Parameter(Mandatory=$true)]
    [string] $Right
)

$Left = Convert-Path $Left
$Right = Convert-Path $Right
$leftAll = Get-ChildItem -Path $Left -Recurse | Sort-Object -Property FullName
$rightAll = Get-ChildItem -Path $Right -Recurse | Sort-Object -Property FullName

$leftOnly = @()
$rightOnly = @()
$same = @()
$different = @()

$i = 0
$j = 0
while ($true) {
    if (($i -ge $leftAll.Length) -or ($j -ge $rightAll.Length)) {
        break
    }

    $lf = $leftAll[$i]
    $rf = $rightAll[$j]
    $ln = $lf.FullName.SubString($Left.Length)
    $rn = $rf.FullName.SubString($Right.Length)
    $cmp = $ln.CompareTo($rn)
    if ($cmp -lt 0) {
        $i += 1
        $leftOnly.Add($ln)
        continue
    }
    elseif ($cmp -gt 0) {
        $j += 1
        $rightOnly.Add($rn)
        continue
    }

    # same name, check content
    $diff = diff (cat $lf.FullName) (cat $rf.FullName)
    if ($null -eq $diff) {
        $same.Add($ln)
    }
    else {
        $different.Add($ln)
    }
}

Write-Host Left-only files:
Write-Host $leftOnly
Write-Host Right-only files:
Write-Host $rightOnly
Write-Host Same files:
Write-Host $same
Write-Host Different files:
Write-Host $different
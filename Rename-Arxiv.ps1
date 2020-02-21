# Rename a pdf downloaded from archive (e.g. 1234-5678.pdf) in this format: "First Author, Title.pdf"

param (
    [Parameter(Mandatory=$true)]
    [string]$Path
)

function Convert-FileName {
    # Replace illegal file name characters by _
    param (
        [string]$Name
    )
    [System.IO.Path]::GetinvalidFileNameChars() | ForEach-Object { $Name = $Name.Replace($_, "_") }
    return $Name
}

$Path = Resolve-Path $Path
$fi = New-Object "System.IO.FileInfo" $Path
$id = [System.IO.Path]::GetFileNameWithoutExtension($fi.FullName)
$data = .\Get-Arxiv.ps1 -Id $id

$author = $data.Authors.Split(',')[0]
$name = Convert-FileName -Name "$($author), $($data.Title).pdf"
Write-Host "$($fi.Name) -> $($name)"
$fi.MoveTo([System.IO.Path]::Combine($fi.Directory.FullName, $name))
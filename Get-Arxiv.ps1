# Get title and author information from Arxiv

param (
    [Parameter(Mandatory=$true)]
    [string]$Id
)

function Find-ClassName {
    param (
        [System.__ComObject] $elem,
        [string] $class
    )

    if ($elem.className -eq $class) {
        return $elem
    }

    $result = $null
    foreach ($child in $elem.children) {
        if ($null -eq $result) {
            $result = Find-ClassName $child $class
        }
    }
    return $result
}

$url = "https://arxiv.org/abs/$Id"

$resp = Invoke-WebRequest $url -UseBasicParsing
$html = New-Object -Com "HTMLFile"
$html.IHTMLDocument2_write($resp.RawContent)

$titleElem = $null
$authorElem = $null
foreach ($elem in $html.all) {
    if ($null -eq $titleElem) {
        $titleElem = Find-ClassName $elem "title mathjax"
    }
    if ($null -eq $authorElem) {
        $authorElem = Find-ClassName $elem "authors"
    }
}

$title = $titleElem.innerText.SubString(6) # remove "Title:"
$authors = $authorElem.innerText.SubString(8) # remove "Authors:", then take first author

Write-Output @{
    Title = $title
    Authors = $authors
}
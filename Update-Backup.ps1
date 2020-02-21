# xcopy one directory to another, copying new files only

param (
    [string] $From,
    [string] $To
)

xcopy $From $To /D /E /Y /L

$confirm = ''
while ($confirm -ne 'y') {
    if ($confirm -eq 'n') {
        exit
    }
    $confirm = Read-Host 'Execute? [y/n]'
}

xcopy $From $To /D /E /Y
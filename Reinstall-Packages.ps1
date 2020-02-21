# Run in Visual Studio Package Manager Console

$packages = Get-Package
foreach ($package in $packages) {
    $id = $package.Id
    $version = $package.Versions[0]
    $project = $package.ProjectName
    
    Uninstall-Package -Id $id -Project $project
    Install-Package -Id $id -Project $project -Version $version
}
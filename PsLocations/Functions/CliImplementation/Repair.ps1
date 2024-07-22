function RepairLocations {
    if (-not (TestLocationsSystemOk)) {
        return
    }

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $locations | ForEach-Object {
        $name = $_.Name
        $pathDirectory = Get-PathDirectory -name $name
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $path = Get-Content -Path $pathFile
        if (-not (Test-Path -Path $path)) {
            RemoveLocation -name $name
        }
    }
}
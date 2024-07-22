function GetLocationWhereIAm {
    if (-not (TestLocationsSystemOk)) {
        return
    }

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $path = (get-location).Path
    [bool]$found = $false

    foreach ($location in $locations) {
        $name = $location.Name
        $pathDirectory = Get-PathDirectory -name $name
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $locPath = Get-Content -Path $pathFile
        if ($path -eq $locPath) {
            $descFile = Join-Path -Path $location.FullName -ChildPath "description.txt"
            $description = Get-Content -Path $descFile
            Write-Host
            Write-Host "Where: You are at location '$name'" -ForegroundColor Green
            Write-Host "What: $description" -ForegroundColor Cyan
            Write-Host
            $found = $true
            break;
        }
    }

    if (-not $found) {
        Write-Host
        Write-Host "You are not at any registered location" -ForegroundColor Red
        Write-Host "Use 'loc add <name> <description>' to add current working direction as a location" -ForegroundColor Green
        Write-Host
    }
}

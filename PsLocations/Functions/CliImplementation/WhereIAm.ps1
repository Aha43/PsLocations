function GetLocationWhereIAm {
    if (-not (TestLocationsSystemOk)) {
        return
    }

    $writeHost = GetWriteUser

    $locationsDir = GetLocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $path = (get-location).Path
    [bool]$found = $false

    foreach ($location in $locations) {
        $name = $location.Name
        $pathDirectory = GetPathDirectory -name $name
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $locPath = Get-Content -Path $pathFile
        if ($path -eq $locPath) {
            $descFile = Join-Path -Path $location.FullName -ChildPath "description.txt"
            $description = Get-Content -Path $descFile
            $found = $true

            [PSCustomObject]@{
                Location = $name
                Description = $description
            }

            break;
        }
    }

    if (-not $found) {
        if ($writeHost) {
            Write-Host
            Write-Host "You are not at any registered location" -ForegroundColor Red
            Write-Host "Use 'loc add <name> <description>' to add current working direction as a location" -ForegroundColor Green
            Write-Host
        }
    }
}

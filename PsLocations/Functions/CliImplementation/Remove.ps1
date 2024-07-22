function RemoveTheLocation {
    param(
        [string]$name
    )

    $debug = GetDebug

    $location = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $location) {
        return $false
    }

    $pathDirectory = GetPathDirectory -name $location.Name
    if ($debug) {
        Write-Host "Removing path directory '$pathDirectory' if exists" -ForegroundColor Yellow
    }
    if (Test-Path -Path $pathDirectory) {
        if ($debug) {
            Write-Host "Removing path directory '$pathDirectory'" -ForegroundColor Yellow
        }

        RemoveDirSafely -debug $debug -function "Remove-Location" -dir $pathDirectory
    }

    $machinesDirectory = GetMachinesDirectory -name $location.Name
    $subDirCount = (Get-ChildItem -Directory -Path $machinesDirectory).Length
    if ($subDirCount -eq 0) {
        if ($debug) {
            Write-Host "Removing location directory '$locationDir'" -ForegroundColor Yellow
        }

        RemoveDirSafely -debug $debug -function "Remove-Location" -dir $location.LocationDir
    }

    return $true
}

function RemoveLocation {
    param(
        [string]$name
    )

    if ($name -eq ".") {
        return RemoveThisLocation
    }
    else {
        return RemoveTheLocation -name $name
    }
}

function RemoveThisLocation {
    $path = (Get-Location).Path
    $locationsDir = GetLocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    foreach ($location in $locations) {
        $name = $location.Name
        $pathDirectory = GetPathDirectory -name $name
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $locPath = Get-Content -Path $pathFile
        if ($path -eq $locPath) {
            return RemoveTheLocation -name $name
        }
    }
    return $false
}

function RemoveLocation {
    param(
        [string]$name
    )

    $debug = GetDebug

    if (-not (TestLocationsSystemOk)) {
        return
    }

    $locationDir = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return
    }

    $pathDirectory = Get-PathDirectory -name $name
    if ($debug) {
        Write-Host "Removing path directory '$pathDirectory' if exists" -ForegroundColor Yellow
    }
    if (Test-Path -Path $pathDirectory) {
        if ($debug) {
            Write-Host "Removing path directory '$pathDirectory'" -ForegroundColor Yellow
        }

        RemoveDirSafely -debug $debug -function "Remove-Location" -dir $pathDirectory
    }

    $machinesDirectory = Get-MachinesDirectory -name $name
    $subDirCount = (Get-ChildItem -Directory -Path $machinesDirectory).Length
    if ($subDirCount -eq 0) {
        if ($debug) {
            Write-Host "Removing location directory '$locationDir'" -ForegroundColor Yellow
        }

        RemoveDirSafely -debug $debug -function "Remove-Location" -dir $locationDir
    }
}

function RemoveThisLocation {

    if (-not (TestLocationsSystemOk)) {
        return
    }

    $path = (Get-Location).Path
    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $locations | ForEach-Object {
        $name = $_.Name
        $pathDirectory = Get-PathDirectory -name $name
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $locPath = Get-Content -Path $pathFile
        if ($path -eq $locPath) {
            RemoveLocation -name $name
        }
    }
}

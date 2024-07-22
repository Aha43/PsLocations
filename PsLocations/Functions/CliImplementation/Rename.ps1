function RenameLocation {
    param(
        [string]$name,
        [string]$newName
    )

    $writeUser = GetWriteUser

    if (-not (Test-ValidLocationName -identifier $newName)) {
        if ($writeUser) {
            Write-Host "Invalid new location name. Must start with a letter or underscore and contain only letters, numbers, and underscores" -ForegroundColor Red
        }
        return
    }

    $location = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $location) {
        return
    }

    $locationsDir = GetLocationsDirectory

    $newLocationDir = Join-Path -Path $locationsDir -ChildPath $newName

    if (Test-Path -Path $newLocationDir) {
        if ($writeUser) {
            Write-Host "Location named '$newName' to rename to already exists" -ForegroundColor Red
        }
        return
    }

    if (Test-Path -Path $location.LocationDir) {
        Move-Item -Path $location.LocationDir -Destination $newLocationDir
    }
    else {
        if ($writeUser) {
            Write-Host "Location to rename '$name' does not exist" -ForegroundColor Red
        }
    }
}

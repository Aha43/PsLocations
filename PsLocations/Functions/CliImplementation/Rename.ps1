function RenameLocation {
    param(
        [string]$name,
        [string]$newName
    )

    if ($newName -eq ".") {
        $newName = (Get-Location).Path | Split-Path -Leaf
    }

    if (-not (Test-ValidLocationName -identifier $newName)) {
        return [PSCustomObject]@{
            Ok = $false
            Error = "Invalid new location name. Must start with a letter or underscore and contain only letters, numbers, and underscores"
        }
    }

    $location = (LookupLocationDir -nameOrPos $name -reportError:$true)
    if (-not $location.Ok) {
        return [PSCustomObject]@{
            Ok = $false
            Error = $location.Error
        }
    }

    $locationsDir = GetLocationsDirectory

    $newLocationDir = Join-Path -Path $locationsDir -ChildPath $newName

    if (Test-Path -Path $newLocationDir) {
        return [PSCustomObject]@{
            Ok = $false
            Error = "Location named '$newName' to rename to already exists"
        }
    }

    if (Test-Path -Path $location.LocationDir) {
        Move-Item -Path $location.LocationDir -Destination $newLocationDir
        return [PSCustomObject]@{
            Ok = $true
            Error = $null
        }
    }
    else {
        return [PSCustomObject]@{
            Ok = $false
            Error = "Location path '$location.LocationDir' does not exist"
        }
    }
}

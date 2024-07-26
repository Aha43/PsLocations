function RemoveTheLocation {
    param(
        [string]$name
    )
    $debug = GetDebug

    $location = (LookupLocationDir -nameOrPos $name -reportError:$true)
    if (-not $location.Ok) {
        return [PSCustomObject]@{
            Ok = $false
            Error = $location.Error
        }
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

    return [PSCustomObject]@{
        Ok = $true
        Error = $null
    }
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
            $result = RemoveTheLocation -name $name
            if ($result.Ok) {
                return [PSCustomObject]@{
                    Ok = $true
                    Error = $null
                }
            }
            else {
                return [PSCustomObject]@{
                    Ok = $false
                    Error = $result.Error
                }
            }
        }
    }
    return [PSCustomObject]@{
        Ok = $false
        Error = "No location found for path '$path'"
    }
}

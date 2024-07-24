function UpdateLocationPath {
    param(
        [string]$name
    )

    $writeUser = GetWriteUser

    if ($name -eq ".") {
        if ($writeUser) {
            Write-Host ". syntax not supported" -ForegroundColor Red
        }
        return $false
    }

    $location = (LookupLocationDir -nameOrPos $name -reportError:$true)
    if (-not $location) {
        return $false
    }

    if (Test-Path -Path $location.LocationDir) {
        $pathDirectory = GetPathDirectory -name $location.Name
        if (-not (Test-Path -Path $pathDirectory)) {
            [void](New-Item -Path $pathDirectory -ItemType Directory)
        }
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"

        $path = (get-location).Path
        $path | Out-File -FilePath $pathFile

        return $true
    }
    else {
        if ($writeUser) {
            Write-Host "Location '$name' does not exist" -ForegroundColor Red
        }
        return $false
    }
}

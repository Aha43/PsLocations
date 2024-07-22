function UpdateLocationPath {
    param(
        [string]$name
    )

    $writeUser = GetWriteUser

    if (-not (TestLocationsSystemOk)) {
        return
    }

    $locationDir = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return
    }

    if (Test-Path -Path $locationDir) {
        $pathDirectory = GetPathDirectory -name $name
        if (-not (Test-Path -Path $pathDirectory)) {
            [void](New-Item -Path $pathDirectory -ItemType Directory)
        }
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"

        $path = (get-location).Path
        $path | Out-File -FilePath $pathFile
    }
    else {
        if ($writeUser) {
            Write-Host "Location '$name' does not exist" -ForegroundColor Red
        }
    }
}
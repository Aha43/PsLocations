function EditDescription {
    param(
        [string]$name,
        [string]$description
    )
    if (-not (TestLocationsSystemOk)) {
        return
    }

    $locationDir = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return
    }

    if (Test-Path -Path $locationDir) {
        $descFile = Join-Path -Path $locationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}
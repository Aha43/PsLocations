function EditDescription {
    param(
        [string]$name,
        [string]$description
    )

    $writeUser = GetWriteUser

    $location = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $location) {
        return
    }

    if (Test-Path -Path $location.LocationDir) {
        $descFile = Join-Path -Path $location.LocationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile
    }
    else {
        if ($writeUser) {
            Write-Host "Location '$name' does not exist" -ForegroundColor Red
        }
    }
}

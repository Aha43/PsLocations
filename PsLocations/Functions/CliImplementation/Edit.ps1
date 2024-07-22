function EditDescription {
    param(
        [string]$name,
        [string]$description
    )

    $writeUser = GetWriteUser

    $locationDir = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return
    }

    if (Test-Path -Path $locationDir) {
        $descFile = Join-Path -Path $locationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile
    }
    else {
        if ($writeUser) {
            Write-Host "Location '$name' does not exist" -ForegroundColor Red
        }
    }
}

function EditDescription {
    param(
        [string]$name,
        [string]$description
    )

    $debug = GetDebug
    $writeUser = GetWriteUser

    $location = (LookupLocationDir -nameOrPos $name -reportError:$true)
    if (-not $location) {
        return
    }

    if ($debug) {
        Write-Host "Editing description for location '$name'" -ForegroundColor Yellow
        Write-Host "Location directory: $($location.LocationDir)" -ForegroundColor Yellow
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

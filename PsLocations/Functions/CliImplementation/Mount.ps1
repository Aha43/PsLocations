function MountLocation {
    param(
        [string]$name
    )

    $debug = GetDebug
    $writeUser = GetWriteUser

    if (-not (TestLocationsSystemOk)) {
        return
    }

    $pos = Convert-ToUnsignedInt -inputString $name
    if ($pos -gt -1) {
        $count = GetLocationCount
        if ($pos -ge $count) {
            if ($writeUser) {
                Write-Host "Location at position $pos does not exist" -ForegroundColor Red
            }
            return
        }

        $name = GetLocationNameAtPosition -position $pos
        if ($debug) {
            Write-Host "Mount-Location: Position $pos is location '$name'" -ForegroundColor Yellow
        }
    }

    $locationDir = GetLocationDirectory -name $name
    if (-not $locationDir) {
        if ($debug) {
            Write-Host "Mount-Location: Location '$name' not found by Get-LocationDirectoryGivenNameOrPos" -ForegroundColor Yellow
        }
        return
    }

    if (Test-Path -Path $locationDir) {
        $pathDirectory = GetPathDirectory -name $name
        if ($debug) {
            Write-Host "Mount-Location: Checking path directory '$pathDirectory'" -ForegroundColor Yellow
        }
        if (-not (Test-Path -Path $pathDirectory)) {
            if ($writeUser) {
                Write-Host "Location '$name' does not have a path for this machine" -ForegroundColor Red
            }
            return
        }
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"

        $path = Get-Content -Path $pathFile
        if (-not (Test-Path -Path $path)) {
            if ($writeUser) {
                Write-Host "Location '$name' does not physical exist ('$path' probably deleted)" -ForegroundColor Red
            }
            return
        }
        Set-Location -Path $path
        $host.UI.RawUI.WindowTitle = $name
    }
    else {
        if ($writeUser) {
            Write-Host "Location '$name' does not exist" -ForegroundColor Red
        }
    }
}

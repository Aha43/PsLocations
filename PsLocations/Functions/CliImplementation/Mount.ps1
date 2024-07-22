function MountLocation {
    param(
        [string]$name
    )

    if (-not (TestLocationsSystemOk)) {
        return
    }

    $pos = Convert-ToUnsignedInt -inputString $name
    if ($pos -gt -1) {
        $count = Get-LocationCount
        if ($pos -ge $count) {
            Write-Host "Location at position $pos does not exist" -ForegroundColor Red
            return
        }

        $name = Get-LocationNameAtPosition -position $pos
        if (GetDebug) {
            Write-Host "Mount-Location: Position $pos is location '$name'" -ForegroundColor Yellow
        }
    }

    $locationDir = Get-LocationDirectory -name $name
    if (-not $locationDir) {
        if (GetDebug) {
            Write-Host "Mount-Location: Location '$name' not found by Get-LocationDirectoryGivenNameOrPos" -ForegroundColor Yellow
        }
        return
    }

    if (Test-Path -Path $locationDir) {
        $pathDirectory = Get-PathDirectory -name $name
        if (GetDebug) {
            Write-Host "Mount-Location: Checking path directory '$pathDirectory'" -ForegroundColor Yellow
        }
        if (-not (Test-Path -Path $pathDirectory)) {
            Write-Host "Location '$name' does not have a path for this machine" -ForegroundColor Red
            return
        }
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"

        $path = Get-Content -Path $pathFile
        if (-not (Test-Path -Path $path)) {
            Write-Host "Location '$name' does not physical exist ('$path' probably deleted)" -ForegroundColor Red
            return
        }
        Set-Location -Path $path
        $host.UI.RawUI.WindowTitle = $name
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}
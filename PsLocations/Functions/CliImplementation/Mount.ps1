function MountLocation {
    param(
        [string]$name
    )
    $debug = GetDebug

    $pos = Convert-ToUnsignedInt -inputString $name
    if ($pos -gt -1) {
        $count = GetLocationCount
        if ($pos -ge $count) {
            return [PSCustomObject]@{
                Ok = $false
                Error = "Location at position $pos does not exist"
            }
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
        return [PSCustomObject]@{
            Ok = $false
            Error = "Location '$name' does not exist"
        }
    }

    if (Test-Path -Path $locationDir) {
        $pathDirectory = GetPathDirectory -name $name
        if ($debug) {
            Write-Host "Mount-Location: Checking path directory '$pathDirectory'" -ForegroundColor Yellow
        }
        if (-not (Test-Path -Path $pathDirectory)) {
            return [PSCustomObject]@{
                Ok = $false
                Error = "Location '$name' does not have a path for this machine"
            }
        }
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"

        $path = Get-Content -Path $pathFile
        if (-not (Test-Path -Path $path)) {
            return [PSCustomObject]@{
                Ok = $false
                Error = "Location '$name' does not physical exist ('$path' probably deleted)"
            }
        }
        Set-Location -Path $path
        $host.UI.RawUI.WindowTitle = $name

        return [PSCustomObject]@{
            Ok = $true
            Error = $null
        }
    }
    else {
        return [PSCustomObject]@{
            Ok = $false
            Error = "Location '$name' does not exist"
        }
    }
}

function Test-LocationsSystemOk {
    $computerName = Get-MachineName
    if (-not $computerName) {
        Write-Host "Locations system not available:" -ForegroundColor Red
        Write-Host "Computer name not available" -ForegroundColor Red
        return $false
    }

    return $true
}

function Get-Status {
    if (-not (Test-LocationsSystemOk)) {
        return
    }
    $computerName = Get-MachineName
    Write-Host
    Write-Host "On computer: $computerName" -ForegroundColor Cyan
    Write-Host "Locations directory: $(Get-LocationsDirectory)" -ForegroundColor Cyan
    Write-Host "Location count: $(Get-LocationCount)" -ForegroundColor Cyan
    $debug = Get-Debug
    Write-Host "Debug mode: $debug" -ForegroundColor Cyan
    Write-Host
}

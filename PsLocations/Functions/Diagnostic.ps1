function TestLocationsSystemOk {
    $computerName = Get-MachineName
    if (-not $computerName) {
        Write-Host "Locations system not available:" -ForegroundColor Red
        Write-Host "Computer name not available" -ForegroundColor Red
        return $false
    }

    return $true
}

function Get-Status {
    if (-not (TestLocationsSystemOk)) {
        return
    }

    return [PSCustomObject]@{
        ComputerName = Get-MachineName
        LocationsDirectory = Get-LocationsDirectory
        LocationCount = Get-LocationCount
        Debug = GetDebug
    }
}

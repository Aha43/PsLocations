function TestLocationsSystemOk {
    $computerName = Get-MachineName
    if (-not $computerName) {
        Write-Host "Locations system not available:" -ForegroundColor Red
        Write-Host "Computer name not available" -ForegroundColor Red
        return $false
    }

    return $true
}

function GetStatus {
    $manifest = Import-PowerShellDataFile -Path $PSScriptRoot/../PsLocations.psd1
    $build = Get-Content -Path $PSScriptRoot/../build.txt

    return [PSCustomObject]@{
        ComputerName = Get-MachineName
        LocationsDirectory = GetLocationsDirectory
        LocationCount = GetLocationCount
        Debug = GetDebug
        Version = $manifest.ModuleVersion
        Build = $build
    }
}

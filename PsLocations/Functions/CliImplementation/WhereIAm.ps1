function GetLocationWhereIAm {
    $debug = GetDebug

    $locationsDir = GetLocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $path = (get-location).Path
    [bool]$found = $false

    foreach ($location in $locations) {
        $name = $location.Name
        $pathDirectory = GetPathDirectory -name $name
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $locPath = Get-Content -Path $pathFile
        if ($path -eq $locPath) {
            $descFile = Join-Path -Path $location.FullName -ChildPath "description.txt"
            $description = Get-Content -Path $descFile
            $found = $true

            if ($debug) {
                Write-Host "GetLocationWhereIAm: Location where I am is '$name'" -ForegroundColor Yellow
            }
            return [PSCustomObject]@{
                Ok = $true
                Error = $null
                Location = $name
                Description = $description
            }

            break;
        }
    }

    if (-not $found) {
        return [PSCustomObject]@{
            Ok = $false
            Error = "You are not at any registered location"
            Location = $null
            Description = $null
        }
    }
}

function RepairLocations {
    try {
        $locationsDir = GetLocationsDirectory
        $locations = Get-ChildItem -Path $locationsDir
        $locations | ForEach-Object {
            $name = $_.Name
            $pathDirectory = GetPathDirectory -name $name
            $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
            $path = Get-Content -Path $pathFile
            if (-not (Test-Path -Path $path)) {
                $retVal = RemoveLocation -name $name
                if (-not $retVal.Ok) {
                    return [PSCustomObject]@{
                        Ok = $false
                        Error = $retVal.Error
                    }
                }
            }
        }

        return [PSCustomObject]@{
            Ok = $true
            Error = $null
        }
    } catch {
        return [PSCustomObject]@{
            Ok = $false
            Error = $_.Exception.Message
        }
    }
}

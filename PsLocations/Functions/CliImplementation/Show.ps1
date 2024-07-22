function TestLocation([string]$name) {
    $pathDirectory = Get-PathDirectory -name $name
    if (-not (Test-Path -Path $pathDirectory)) {
        return $false
    }
    $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"

    $path = Get-Content -Path $pathFile
    return (Test-Path -Path $path)
}

function ShowLocations {
    param (
        [switch]$PassThru
    )

    $debug = GetDebug
    $writeUser = GetWriteUser

    if (-not (TestLocationsSystemOk)) {
        return
    }

    $retVal = @()

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    [int]$pos = 0

    if (-not $PassThru) {
        if ($writeUser) {
            Write-Host
        }
    }

    $locations | ForEach-Object {
        $name = $_.Name
        [bool]$exist = Testlocation -name $name
        $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
        $description = Get-Content -Path $descFile

        $pathDirectory = Get-PathDirectory -name $name
        if ($debug) {
            Write-Host "Show-Locations: Checking path directory '$pathDirectory'" -ForegroundColor Yellow
        }

        if (Test-Path -Path $pathDirectory) {
            $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
            $path = Get-Content -Path $pathFile
            $machineNames = GetMachineNamesForLocation -name $name

            $location = [PSCustomObject]@{
                Pos = $pos
                Name = $name
                Description = $description
                Path = $path
                MachineNames = $machineNames
                Exist = $exist
            }

            $retVal += $location

            if (-not $PassThru) {
                if ($writeUser) {
                    if (-not $exist) {
                        Write-Host "$pos" -NoNewline -ForegroundColor Red
                        Write-Host " - $name" -NoNewline -ForegroundColor Red
                        Write-Host " - $description" -NoNewline -ForegroundColor Red
                        Write-Host " - $path" -NoNewline -ForegroundColor Red
                        Write-Host " - $machineNames" -ForegroundColor Red
                    }
                    else {
                        Write-Host "$pos" -NoNewline -ForegroundColor Yellow
                        Write-Host " - $name" -NoNewline -ForegroundColor Cyan
                        Write-Host " - $description" -NoNewline -ForegroundColor Green
                        Write-Host " - $path" -NoNewline -ForegroundColor Cyan
                        Write-Host " - $machineNames" -ForegroundColor Yellow
                    }
                }
            }
        }

        $pos++
    }
    if (-not $PassThru) {
        if ($writeUser) {
            Write-Host
        }
    }

    if ($PassThru) {
        return $retVal
    }
}

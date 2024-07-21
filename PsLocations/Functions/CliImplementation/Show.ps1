function Show-Locations {
    param (
        [switch]$PassThru
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $retVal = @()

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    [int]$pos = 0

    if (-not $PassThru) {
        Write-Host
    }
    Write-Host
    $locations | ForEach-Object {
        $name = $_.Name
        [bool]$exist = Test-location -name $name
        $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
        $description = Get-Content -Path $descFile

        $pathDirectory = Get-PathDirectory -name $name
        if (Get-Debug) {
            Write-Host "Show-Locations: Checking path directory '$pathDirectory'" -ForegroundColor Yellow
        }

        if (Test-Path -Path $pathDirectory) {
            $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
            $path = Get-Content -Path $pathFile
            $machineNames = Get-MachineNamesForLocation -name $name

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

        $pos++
    }
    if (-not $PassThru) {
        Write-Host
    }

    if ($PassThru) {
        return $retVal
    }
}

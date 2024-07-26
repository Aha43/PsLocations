function TestLocation([string]$name) {
    $pathDirectory = GetPathDirectory -name $name
    if (-not (Test-Path -Path $pathDirectory)) {
        return $false
    }
    $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"

    $path = Get-Content -Path $pathFile
    return (Test-Path -Path $path)
}

function GetLocations {
    param (
        [switch]$PassThru
    )
    $debug = GetDebug

    $retVal = @()

    $locationsDir = GetLocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    [int]$pos = 0

    if (-not $PassThru) {
            Write-Host
    }

    $locations | ForEach-Object {
        $name = $_.Name
        [bool]$exist = Testlocation -name $name

        $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
        $description = Get-Content -Path $descFile

        $pathDirectory = GetPathDirectory -name $name
        if ($debug) {
            Write-Host "Show-Locations: Checking path directory '$pathDirectory'" -ForegroundColor Yellow
        }

        $path = "?"
        if (Test-Path -Path $pathDirectory) {
            $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
            $path = Get-Content -Path $pathFile
            if (-not (Test-Path -Path $path)) {
                $path = "!"
            }
        }
        $machineNames = GetMachineNamesForLocation -name $name

        $location = [PSCustomObject]@{
            Pos = $pos
            Name = $name
            Description = $description
            Path = $path
            MachineNames = $machineNames.Split(" ")
            Exist = $exist
        }

        $retVal += $location

        if (-not $PassThru) {
            Write-Host "$pos" -NoNewline -ForegroundColor Yellow
            Write-Host " - $name" -NoNewline -ForegroundColor Cyan
            Write-Host " - $description" -NoNewline -ForegroundColor Green
            Write-Host " - $path" -NoNewline -ForegroundColor Cyan
            Write-Host " - $machineNames" -ForegroundColor Yellow
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

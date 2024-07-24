function GetLocationsDirectory {
    $retVal = Join-Path -Path $HOME -ChildPath ".locations"

    if ($env:LocHome) {
        $retVal = $env:LocHome
    }

    if (-not (Test-Path -Path $retVal)) {
        [void](New-Item -Path $retVal -ItemType Directory)
    }

    return $retVal
}

function GetLocationDirectory {
    param (
        [string]$name
    )

    $locationsDir = GetLocationsDirectory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    return $locationDir
}

function LookupLocationDir {
    param (
        [string]$nameOrPos,
        [switch]$reportError
    )

    $debug = GetDebug
    $writeUser = GetWriteUser

    if ($nameOrPos -eq ".") {
        $loc = GetLocationWhereIAm
        if ($loc) {
            $nameOrPos = $loc.Location
            if ($debug) {
                Write-Host "GetLocationDirectoryGivenNameOrPos: Location where I am is '$nameOrPos'" -ForegroundColor Yellow
            }
        }
        else {
            if ($reportError) {
                if ($writeUser) {
                    Write-Host "You are not at any registered location" -ForegroundColor Red
                }
            }
            return $null
        }
    }

    $pos = Convert-ToUnsignedInt -inputString $nameOrPos
    if ($pos -gt -1) {
        $count = GetLocationCount
        if ($pos -ge $count) {
            if ($reportError) {
                if ($writeUser) {
                    Write-Host "Location '$nameOrPos' does not exist" -ForegroundColor Red
                }
            }
            return $null
        }

        $nameOrPos = GetLocationNameAtPosition -position $pos
        if ($debug) {
            Write-Host "Get-LocationDirectoryGivenNameOrPos: Position $pos is location '$nameOrPos'" -ForegroundColor Yellow
        }
    }

    $locationDir = GetLocationDirectory -name $nameOrPos
    if (Test-Path -Path $locationDir) {
        if ($debug) {
            Write-Host "Get-LocationDirectoryGivenNameOrPos: Location directory '$locationDir' exists" -ForegroundColor Yellow
        }
        return [PSCustomObject]@{
            LocationDir = $locationDir
            Name = $nameOrPos
        }
    }
    else {
        if ($reportError) {
            if ($writeUser) {
                Write-Host "Location '$nameOrPos' does not exist" -ForegroundColor Red
            }
        }
        return $null
    }
}

function GetMachinesDirectory {
    param (
        [string]$name
    )

    $locationDir = GetLocationDirectory -name $name
    $machinesDirectory = Join-Path -Path $locationDir -ChildPath "machines"
    return $machinesDirectory
}

function GetPathDirectory {
    param (
        [string]$name
    )

    $machinesDirectory = GetMachinesDirectory -name $name
    $machineName = Get-MachineName
    $pathDirectory = Join-Path -Path $machinesDirectory -ChildPath $machineName
    return $pathDirectory
}

function GetNotesDir {
    param(
        [string]$name
    )

    $location = (LookupLocationDir -nameOrPos $name -reportError:$true)
    if (-not $location) {
        return $null
    }

    $notesDir = Join-Path -Path $location.LocationDir -ChildPath "notes"
    if (-not (Test-Path -Path $notesDir)) {
        [void](New-Item -Path $notesDir -ItemType Directory)
    }
    return $notesDir
}

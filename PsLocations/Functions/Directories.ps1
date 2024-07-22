function Get-LocationsDirectory {
    $retVal = Join-Path -Path $HOME -ChildPath ".locations"

    if ($env:LocHome) {
        $retVal = $env:LocHome
    }

    if (-not (Test-Path -Path $retVal)) {
        [void](New-Item -Path $retVal -ItemType Directory)
    }

    return $retVal
}

function Get-LocationDirectory {
    param (
        [string]$name
    )

    $locationsDir = Get-LocationsDirectory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    return $locationDir
}

function GetLocationDirectoryGivenNameOrPos {
    param (
        [string]$nameOrPos,
        [switch]$reportError
    )

    $pos = Convert-ToUnsignedInt -inputString $nameOrPos
    if ($pos -gt -1) {
        $count = Get-LocationCount
        if ($pos -ge $count) {
            if ($reportError) {
                Write-Host "Location '$nameOrPos' does not exist" -ForegroundColor Red
            }
            return $null
        }

        $nameOrPos = Get-LocationNameAtPosition -position $pos
        if (Get-Debug) {
            Write-Host "Get-LocationDirectoryGivenNameOrPos: Position $pos is location '$nameOrPos'" -ForegroundColor Yellow
        }
    }

    $locationDir = Get-LocationDirectory -name $nameOrPos
    if (Test-Path -Path $locationDir) {
        if (Get-Debug) {
            Write-Host "Get-LocationDirectoryGivenNameOrPos: Location directory '$locationDir' exists" -ForegroundColor Yellow
        }
        return $locationDir
    }
    else {
        if ($reportError) {
            Write-Host "Location '$nameOrPos' does not exist" -ForegroundColor Red
        }
        return $null
    }
}

function Get-MachinesDirectory {
    param (
        [string]$name
    )

    $locationDir = Get-LocationDirectory -name $name
    $machinesDirectory = Join-Path -Path $locationDir -ChildPath "machines"
    return $machinesDirectory
}

function Get-PathDirectory {
    param (
        [string]$name
    )

    $machinesDirectory = Get-MachinesDirectory -name $name
    $machineName = Get-MachineName
    $pathDirectory = Join-Path -Path $machinesDirectory -ChildPath $machineName
    return $pathDirectory
}

function Get-NotesDir {
    param(
        [string]$name
    )

    $locationDir = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return $null
    }

    $notesDir = Join-Path -Path $locationDir -ChildPath "notes"
    if (-not (Test-Path -Path $notesDir)) {
        [void](New-Item -Path $notesDir -ItemType Directory)
    }
    return $notesDir
}

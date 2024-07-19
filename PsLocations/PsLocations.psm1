. $PSScriptRoot/Functions/Debug.ps1
. $PSScriptRoot/Functions/Utilities.ps1
. $PSScriptRoot/Functions/Directories.ps1
. $PSScriptRoot/Functions/Diagnostic.ps1
. $PSScriptRoot/Functions/Help.ps1

. $PSScriptRoot/Functions/CliImplementation/Add.ps1
. $PSScriptRoot/Functions/CliImplementation/Show.ps1

function Get-MachineNamesForLocation {
    param (
        [string]$name
    )

    $machinesDirectory = Get-MachinesDirectory -name $name
    if (Get-Debug) {
        Write-Host "Get-MachineNamesForLocation: Checking path directory '$machinesDirectory'" -ForegroundColor Yellow
    }   

    $machineNames = @()
    if (Test-Path -Path $machinesDirectory) {
        $machineNames = Get-ChildItem -Path $machinesDirectory -Directory | ForEach-Object {
            $_.Name
        }
    }
    return $machineNames
}

function Get-LocationCount {
    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    return $locations.Length
}

function Get-LocationNameAtPosition {
    param (
        [int]$position
    )

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $retVal = $null
    if ($locations.Length -gt 0) {
        $index = 0
        $locations | ForEach-Object {
            if ($index -eq $position) {
                $retVal = $_.Name
            }
            $index++
        }
    }
    return $retVal
}

function Test-Location([string]$name) {
    $pathDirectory = Get-PathDirectory -name $name
    if (-not (Test-Path -Path $pathDirectory)) {
        return $false
    }
    $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
    
    $path = Get-Content -Path $pathFile
    return (Test-Path -Path $path)
}

function Get-NextNoteFile {
    param(
        [string]$name
    )
    $notesDir = Get-NotesDir -name $name
    if (-not $notesDir) {
        return $null
    }

    $timeStamp = Get-Timestamp
    $noteFile = Join-Path -Path $notesDir -ChildPath "$timeStamp.txt"
    return $noteFile
}

function Mount-Location {
    param(
        [string]$name
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $pos = Convert-ToUnsignedInt -inputString $name
    if ($pos -gt -1) {
        $count = Get-LocationCount
        if ($pos -ge $count) {
            Write-Host "Location at position $pos does not exist" -ForegroundColor Red
            return
        }

        $name = Get-LocationNameAtPosition -position $pos
        if (Get-Debug) {
            Write-Host "Mount-Location: Position $pos is location '$name'" -ForegroundColor Yellow
        }
    }
    
    $locationDir = Get-LocationDirectory -name $name
    if (-not $locationDir) {
        if (Get-Debug) {
            Write-Host "Mount-Location: Location '$name' not found by Get-LocationDirectoryGivenNameOrPos" -ForegroundColor Yellow
        }
        return
    }

    if (Test-Path -Path $locationDir) {
        $pathDirectory = Get-PathDirectory -name $name
        if (Get-Debug) {
            Write-Host "Mount-Location: Checking path directory '$pathDirectory'" -ForegroundColor Yellow
        }
        if (-not (Test-Path -Path $pathDirectory)) {
            Write-Host "Location '$name' does not have a path for this machine" -ForegroundColor Red
            return
        }
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        
        $path = Get-Content -Path $pathFile
        if (-not (Test-Path -Path $path)) {
            Write-Host "Location '$name' does not physical exist ('$path' probably deleted)" -ForegroundColor Red
            return
        }
        Set-Location -Path $path
        $host.UI.RawUI.WindowTitle = $name
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}

function Update-LocationPath {
    param(
        [string]$name
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $locationDir = (Get-LocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return
    }

    if (Test-Path -Path $locationDir) {
        $pathDirectory = Get-PathDirectory -name $name
        if (-not (Test-Path -Path $pathDirectory)) {
            [void](New-Item -Path $pathDirectory -ItemType Directory)
        }
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        
        $path = (get-location).Path
        $path | Out-File -FilePath $pathFile
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}

function Add-LocationNote {
    param(
        [string]$name,
        [string]$note
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $noteFile = Get-NextNoteFile -name $name
    if (-not $noteFile) {
        return
    }

    $note | Out-File -FilePath $noteFile

    $env:LocLastNoteFile = $noteFile
}

function Show-Notes {
    param(
        [string]$name
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $notesDir = Get-NotesDir -name $name
    if (-not $notesDir) {
        return
    }

    $notes = Get-ChildItem -Path $notesDir
    $notes | ForEach-Object {
        $fullName = $_.FullName
        $note = Get-Content -Path $fullName
        $noteTimestamp = [System.IO.Path]::GetFileNameWithoutExtension($fullName)
        Write-Host ($noteTimestamp + " - " + $note) -ForegroundColor Cyan
    }
}

function Rename-Location {
    param(
        [string]$name,
        [string]$newName
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    if (-not (Test-ValidLocationName -identifier $newName)) {
        Write-Host "Invalid new location name. Must start with a letter or underscore and contain only letters, numbers, and underscores" -ForegroundColor Red
        return
    }

    $locationDir = (Get-LocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return
    }

    $locationsDir = Get-LocationsDirectory

    $newLocationDir = Join-Path -Path $locationsDir -ChildPath $newName

    if (Test-Path -Path $newLocationDir) {
        Write-Host "Location named '$newName' to rename to already exists" -ForegroundColor Red
        return
    }

    if (Test-Path -Path $locationDir) {
        Move-Item -Path $locationDir -Destination $newLocationDir
    }
    else {
        Write-Host "Location to rename '$name' does not exist" -ForegroundColor Red
    }
}

function Edit-Description {
    param(
        [string]$name,
        [string]$description
    )
    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $locationDir = (Get-LocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return
    }

    if (Test-Path -Path $locationDir) {
        $descFile = Join-Path -Path $locationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile
    }
    else {
        Write-Host "Location '$name' does not exist" -ForegroundColor Red
    }
}

function Repair-Locations {

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $locations | ForEach-Object {
        $name = $_.Name
        $pathDirectory = Get-PathDirectory -name $name
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $path = Get-Content -Path $pathFile
        if (-not (Test-Path -Path $path)) {
            Remove-Location -name $name
        }
    }
}

function Remove-Location {
    param(
        [string]$name
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $locationDir = (Get-LocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return
    }

    $pathDirectory = Get-PathDirectory -name $name
    if (Get-Debug) {
        Write-Host "Removing path directory '$pathDirectory' if exists" -ForegroundColor Yellow
    }
    if (Test-Path -Path $pathDirectory) {
        if (Get-Debug) {
            Write-Host "Removing path directory '$pathDirectory'" -ForegroundColor Yellow
        }
        Remove-Item -Path $pathDirectory -Recurse
    }

    $machinesDirectory = Get-MachinesDirectory -name $name
    $subDirCount = (Get-ChildItem -Directory -Path $machinesDirectory).Length
    if ($subDirCount -eq 0) {
        if (Get-Debug) {
            Write-Host "Removing location directory '$locationDir'" -ForegroundColor Yellow
        }
        Remove-Item -Path $locationDir -Recurse
    }
}

function Remove-ThisLocation {

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $path = (Get-Location).Path
    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $locations | ForEach-Object {
        $name = $_.Name
        $pathDirectory = Get-PathDirectory -name $name
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $locPath = Get-Content -Path $pathFile
        if ($path -eq $locPath) {
            Remove-Location -name $name
        }
    }
}

function Get-LocationWhereIAm {
    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $path = (get-location).Path
    [bool]$found = $false
    if ($locations.Length -gt 0) {
        $locations | ForEach-Object {
            $name = $_.Name
            $pathDirectory = Get-PathDirectory -name $name
            $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
            $locPath = Get-Content -Path $pathFile
            if ($path -eq $locPath) {
                $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
                $description = Get-Content -Path $descFile
                Write-Host
                Write-Host "Where: You are at location '$name'" -ForegroundColor Green
                Write-Host "What: $description" -ForegroundColor Cyan
                Write-Host
                $found = $true
            }
        }
    }
    
    if (-not $found) {
        Write-Host
        Write-Host "You are not at any registered location" -ForegroundColor Red
        Write-Host "Use 'loc add <name> <description>' to add current working direction as a location" -ForegroundColor Green
        Write-Host
    }
}

# cli
function Loc {
    if ($args.Length -lt 1) {
        Write-Host
        Write-Host "Usage: loc <action> ..." -ForegroundColor Red
        Write-Host "For more help: loc help" -ForegroundColor Red
        Write-Host
        return
    }

    $action = $args[0]
    
    if ($action -eq "add") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc add <name> <description>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        $description = $args[2]
        Add-Location -name $name -description $description
    }
    elseif ($action -eq "status") {
        Get-Status
    }
    elseif ($action -eq "debug") {
        Switch-Debug
    }
    elseif ($action -eq "note") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc note <name> <note>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        $note = $args[2]
        Add-LocationNote -name $name -note $note
    }
    elseif ($action -eq "notes") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc notes <name>" -ForegroundColor Red
        }

        $name = $args[1]
        Show-Notes -name $name
    }
    elseif ($action -eq "update") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc update <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        Update-LocationPath -name $name
    }
    elseif ($action -eq "rename") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc rename <name> <new-name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        $newName = $args[2]
        Rename-Location -name $name -newName $newName
    }
    elseif ($action -eq "edit") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc edit <name> <description>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        $description = $args[2]
        edit-description -name $name -description $description
    }
    elseif ($action -eq "list" -or $action -eq "ls" -or $action -eq "l") {
        Show-Locations
    }
    elseif ($action -eq "remove") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc remove <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        Remove-Location -name $name
    }
    elseif ($action -eq "remove-this") {
        Remove-ThisLocation
    }
    elseif ($action -eq "repair") {
        Repair-Locations
    }
    elseif ($action -eq "goto" -or $action -eq "go") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc goto <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        Mount-Location -name $name
    }
    elseif ($action -eq "where") {
        Get-LocationWhereIAm
    }
    elseif ($action -eq "help") {
        if ($args.Length -lt 2) {
            Get-LocCliHelp
            return
        }

        $subAction = $args[1]
        Get-SubActionHelp -action $subAction
    }
    else {
        loc go $action
    }
}

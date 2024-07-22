. $PSScriptRoot/Functions/Debug.ps1
. $PSScriptRoot/Functions/Utilities.ps1
. $PSScriptRoot/Functions/Directories.ps1
. $PSScriptRoot/Functions/Diagnostic.ps1
. $PSScriptRoot/Functions/Help.ps1

. $PSScriptRoot/Functions/CliImplementation/Add.ps1
. $PSScriptRoot/Functions/CliImplementation/Mount.ps1
. $PSScriptRoot/Functions/CliImplementation/Show.ps1
. $PSScriptRoot/Functions/CliImplementation/AddNote.ps1
. $PSScriptRoot/Functions/CliImplementation/Notes.ps1

function Get-MachineNamesForLocation {
    param (
        [string]$name
    )

    $machinesDirectory = Get-MachinesDirectory -name $name
    if (GetDebug) {
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
    if ($locations.Length -gt 0) {
        $index = 0
        foreach ($location in $locations) {
            if ($index -eq $position) {
                return $location.Name
            }
            $index++
        }
    }
    return $null
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

    if (-not (TestLocationsSystemOk)) {
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
        if (GetDebug) {
            Write-Host "Mount-Location: Position $pos is location '$name'" -ForegroundColor Yellow
        }
    }

    $locationDir = Get-LocationDirectory -name $name
    if (-not $locationDir) {
        if (GetDebug) {
            Write-Host "Mount-Location: Location '$name' not found by Get-LocationDirectoryGivenNameOrPos" -ForegroundColor Yellow
        }
        return
    }

    if (Test-Path -Path $locationDir) {
        $pathDirectory = Get-PathDirectory -name $name
        if (GetDebug) {
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

function UpdateLocationPath {
    param(
        [string]$name
    )

    if (-not (TestLocationsSystemOk)) {
        return
    }

    $locationDir = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
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

function Rename-Location {
    param(
        [string]$name,
        [string]$newName
    )

    if (-not (TestLocationsSystemOk)) {
        return
    }

    if (-not (Test-ValidLocationName -identifier $newName)) {
        Write-Host "Invalid new location name. Must start with a letter or underscore and contain only letters, numbers, and underscores" -ForegroundColor Red
        return
    }

    $locationDir = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
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
    if (-not (TestLocationsSystemOk)) {
        return
    }

    $locationDir = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
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

function RepairLocations {

    if (-not (TestLocationsSystemOk)) {
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
            RemoveLocation -name $name
        }
    }
}

function RemoveLocation {
    param(
        [string]$name
    )

    [bool]$debug = GetDebug

    if (-not (TestLocationsSystemOk)) {
        return
    }

    $locationDir = (GetLocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return
    }

    $pathDirectory = Get-PathDirectory -name $name
    if ($debug) {
        Write-Host "Removing path directory '$pathDirectory' if exists" -ForegroundColor Yellow
    }
    if (Test-Path -Path $pathDirectory) {
        if ($debug) {
            Write-Host "Removing path directory '$pathDirectory'" -ForegroundColor Yellow
        }

        RemoveDirSafely -debug $debug -function "Remove-Location" -dir $pathDirectory
    }

    $machinesDirectory = Get-MachinesDirectory -name $name
    $subDirCount = (Get-ChildItem -Directory -Path $machinesDirectory).Length
    if ($subDirCount -eq 0) {
        if (GetDebug) {
            Write-Host "Removing location directory '$locationDir'" -ForegroundColor Yellow
        }

        RemoveDirSafely -debug $debug -function "Remove-Location" -dir $locationDir
    }
}

function RemoveThisLocation {

    if (-not (TestLocationsSystemOk)) {
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
            RemoveLocation -name $name
        }
    }
}

function Get-LocationWhereIAm {
    if (-not (TestLocationsSystemOk)) {
        return
    }

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $path = (get-location).Path
    [bool]$found = $false

    foreach ($location in $locations) {
        $name = $location.Name
        $pathDirectory = Get-PathDirectory -name $name
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $locPath = Get-Content -Path $pathFile
        if ($path -eq $locPath) {
            $descFile = Join-Path -Path $location.FullName -ChildPath "description.txt"
            $description = Get-Content -Path $descFile
            Write-Host
            Write-Host "Where: You are at location '$name'" -ForegroundColor Green
            Write-Host "What: $description" -ForegroundColor Cyan
            Write-Host
            $found = $true
            break;
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
        AddLocation -name $name -description $description
    }
    elseif ($action -eq "status") {
        GetStatus
    }
    elseif ($action -eq "debug") {
        SwitchDebug
    }
    elseif ($action -eq "note") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc note <name> <note>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        $note = $args[2]
        AddLocationNote -name $name -note $note
    }
    elseif ($action -eq "notes") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc notes <name>" -ForegroundColor Red
        }

        $name = $args[1]
        ShowNotes -name $name
    }
    elseif ($action -eq "update") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc update <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        UpdateLocationPath -name $name
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
        ShowLocations
    }
    elseif ($action -eq "show") {
        $l = (ShowLocations -PassThru)
        return $l
    }
    elseif ($action -eq "remove") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc remove <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        RemoveLocation -name $name
    }
    elseif ($action -eq "remove-this") {
        RemoveThisLocation
    }
    elseif ($action -eq "repair") {
        RepairLocations
    }
    elseif ($action -eq "goto" -or $action -eq "go") {
        if ($args.Length -lt 2) {
            Write-Host "Usage: loc goto <name>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        MountLocation -name $name
    }
    elseif ($action -eq "where") {
        Get-LocationWhereIAm
    }
    elseif ($action -eq "help") {
        if ($args.Length -lt 2) {
            GetLocCliHelp
            return
        }

        $subAction = $args[1]
        GetSubActionHelp -action $subAction
    }
    else {
        loc go $action
    }
}

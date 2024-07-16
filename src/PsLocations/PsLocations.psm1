
#
# Internal functions
#

# Utility functions

$Debug = $true

function Get-MachineName {
    return $env:COMPUTERNAME
}

function Test-LocationsSystemOk {
    $computerName = Get-MachineName
    if (-not $computerName) {
        Write-Host "Locations system not available:" -ForegroundColor Red
        Write-Host "Computer name not available" -ForegroundColor Red
        return $false
    }

    return $true
}

function Convert-ToUnsignedInt {
    param (
        [string]$inputString
    )

    # Try to convert the input string to an integer
    [int]$number = 0
    if (-not [int]::TryParse($inputString, [ref]$number)) {
        return -1
    }

    # Check if the number is negative
    if ($number -lt 0) {
        return -1
    }

    return [uint32]$number
}

function Get-Timestamp {
    return (Get-Date).ToString("yyyyMMddHHmmss")
}

# Git functions

function Get-GitBranch {
    $locationsDir = Get-LocationsDirectory
    Push-Location -Path $locationsDir 
        $branch = & git rev-parse --abbrev-ref HEAD 2> $null
    Pop-Location
    if ($branch) {
        return $branch
    }
    return ""
}

function Get-LocationsDirectory {
    $retVal = Join-Path -Path $HOME -ChildPath ".locations"
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

function Get-LocationDirectoryGivenNameOrPos {
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
    }

    $locationDir = Get-LocationDirectory -name $nameOrPos
    if (Test-Path -Path $locationDir) {
        return $locationDir
    }
    else {
        if ($reportError) {
            Write-Host "Location '$nameOrPos' does not exist" -ForegroundColor Red
        }
        return $null
    }
}

function Get-MachineNamesForLocation {
    param (
        [string]$name
    )

    $locationsDir = Get-LocationsDirectory
    $locationDir = Join-Path -Path $locationsDir -ChildPath $name
    $machineNames = @()
    if (Test-Path -Path $locationDir) {
        $machineNames = Get-ChildItem -Path $locationDir -Directory | ForEach-Object {
            $_.Name
        }
    }
    return $machineNames
}

function Test-ValidLocationName {
    param (
        [string]$identifier
    )

    $regex = '^[a-zA-Z_][a-zA-Z0-9_]*$'
    
    if ($identifier -match $regex) {
        return $true
    } else {
        return $false
    }
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
    $locationDir = Get-LocationDirectory -name $name

    $machineName = Get-MachineName
    $pathDirectory = Join-Path -Path $locationDir -ChildPath $machineName
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

function Get-NotesDir {
    param(
        [string]$name
    )

    $locationDir = (Get-LocationDirectoryGivenNameOrPos -nameOrPos $name -reportError:$true)
    if (-not $locationDir) {
        return $null
    }

    $notesDir = Join-Path -Path $locationDir -ChildPath "notes"
    if (-not (Test-Path -Path $notesDir)) {
        [void](New-Item -Path $notesDir -ItemType Directory)
    }
    return $notesDir
}

function Get-LocAddHelp {
    Write-Host
    Write-Host "Usage: loc add <name> <description>" -ForegroundColor Green
    Write-Host "Add the current working directory as a location with the given name and description" -ForegroundColor Green
    Write-Host
}

function Get-LocNoteHelp {
    Write-Host
    Write-Host "Usage: loc note <name | pos> <note>" -ForegroundColor Green
    Write-Host "Add a note to the location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host
}

function Get-LocNotesHelp {
    Write-Host
    Write-Host "Usage: loc notes <name | pos>" -ForegroundColor Green
    Write-Host "Show notes for the location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host
}

function Get-LocUpdateHelp {
    Write-Host
    Write-Host "Usage: loc update <name | pos>" -ForegroundColor Green
    Write-Host "Update the path of a location with the given name (or position in location list) to the current working directory" -ForegroundColor Green
    Write-Host
}

function Get-LocRenameHelp {
    Write-Host
    Write-Host "Usage: loc rename <name | pos> <new-name>" -ForegroundColor Green
    Write-Host "Rename a location with the given name or pos (or position in location list) to the new name" -ForegroundColor Green
    Write-Host
}

function Get-LocEditHelp {
    Write-Host
    Write-Host "Usage: loc edit <name | pos> <description>" -ForegroundColor Green
    Write-Host "Edit the description of a location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host
}

function Get-LocListHelp {
    Write-Host
    Write-Host "Usage: loc list" -ForegroundColor Green
    Write-Host "List all locations" -ForegroundColor Green
    Write-Host "You can also use 'loc ls' or 'loc l' to list all locations" -ForegroundColor Green
    Write-Host
}

function Get-LocRemoveHelp {
    Write-Host
    Write-Host "Usage: loc remove <name | pos>" -ForegroundColor Green
    Write-Host "Remove a location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host
}

function Get-LocRemoveThisHelp {
    Write-Host
    Write-Host "Usage: loc remove-this" -ForegroundColor Green
    Write-Host "Remove the location you are currently at (do not worry the physical directory not deleted)" -ForegroundColor Green
    Write-Host
}

function Get-LocRepairHelp {
    Write-Host
    Write-Host "Usage: loc repair" -ForegroundColor Green
    Write-Host "Remove locations that do not physically exist" -ForegroundColor Green
    Write-Host
}

function Get-LocGotoHelp {
    Write-Host
    Write-Host "Usage: loc goto <name | pos>" -ForegroundColor Green
    Write-Host "Go to the location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host "You can also use 'loc go <name | pos>' to go to a location" -ForegroundColor Green
    Write-Host "Finally, you can use 'loc <name | pos>' to go to a location" -ForegroundColor Green
    Write-Host
}

function Get-LocWhereHelp {
    Write-Host
    Write-Host "Usage: loc where" -ForegroundColor Green
    Write-Host "Show the location you are currently at" -ForegroundColor Green
    Write-Host
}

function Get-StatusHelp {
    Write-Host
    Write-Host "Usage: loc status" -ForegroundColor Green
    Write-Host "Show the status of the location system" -ForegroundColor Green
    Write-Host
}

function Get-LocCliActions {
    $commands = @(
        "add",
        "note",
        "notes",
        "update",
        "rename",
        "edit",
        "list",
        "remove",
        "remove-this",
        "repair",
        "goto",
        "where",
        "status"
    )
    return $commands
}

function Get-LocCliHelp {
    $actions = (Get-LocCliActions) -join ", "
    Write-Host
    Write-Host "loc - A location management and navigation command line interface" -ForegroundColor Green
    Write-Host 
    Write-Host "Usage: loc <action> ..." -ForegroundColor Green
    Write-Host "Actions: $actions" -ForegroundColor Green
    Write-Host
    Write-Host "Use 'loc help <action>' for more information on a specific action" -ForegroundColor Green
    Write-Host
}

# Exported functions

function Get-Status {
    if (-not (Test-LocationsSystemOk)) {
        return
    }
    $computerName = Get-MachineName
    Write-Host "On computer: $computerName" -ForegroundColor Cyan
}

function Add-Location {
    param(
        [string]$name,
        [string]$description
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }   

    if (-not (Test-ValidLocationName -identifier $name)) {
        Write-Host "Invalid location name. Must start with a letter or underscore and contain only letters, numbers, and underscores" -ForegroundColor Red
        return
    }

    $locationDir = Get-LocationDirectory -name $name
    if (-not (Test-Path -Path $locationDir)) {
        [void](New-Item -Path $locationDir -ItemType Directory)
    
        $machineName = Get-MachineName
        $pathDirectory = Join-Path -Path $locationDir -ChildPath $machineName
        
        if ($Debug) {
            Write-Host "Creates path directory '$pathDirectory'" -ForegroundColor Yellow
        }

        [void](New-Item -Path $pathDirectory -ItemType Directory)

        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $location = (Get-Location).Path
        $location | Out-File -FilePath $pathFile

        $descFile = Join-Path -Path $locationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile
    }
    else {
        if ($Debug) {
            Write-Host "'$locationDir' do exists" -ForegroundColor Yellow
        } 
        Write-Host "Location named '$name' already added" -ForegroundColor Red
        Write-Host "Use 'loc update $name' to update the path or add for the machine you are on" -ForegroundColor Green
    }
}

function Mount-Location {
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
        $machineName = Get-MachineName
        $pathDirectory = Join-Path -Path $locationDir -ChildPath $machineName
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
        
        $machineName = Get-MachineName
        $pathDirectory = Join-Path -Path $locationDir -ChildPath $machineName
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

function Show-Locations {
    # param (
    #     [switch]$showMachineNames
    # )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    [int]$pos = 0
    Write-Host
    $locations | ForEach-Object {
        $name = $_.Name
        [bool]$exist = Test-location -name $name
        $descFile = Join-Path -Path $_.FullName -ChildPath "description.txt"
        $description = Get-Content -Path $descFile

        $machineName = Get-MachineName
        $pathDirectory = Join-Path -Path $_.FullName -ChildPath $machineName
        if (Test-Path -Path $pathDirectory) {
            $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
            $path = Get-Content -Path $pathFile
            $machineNames = Get-MachineNamesForLocation -name $name
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
                Write-Host " - $machineNames" -ForegroundColor Cyan
            }    
        }
        
        $pos++
    }
    Write-Host
}

function Repair-Locations {

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $locationsDir = Get-LocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    $locations | ForEach-Object {
        $pathDirectory = Join-Path -Path $_.FullName -ChildPath (Get-MachineName)
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $path = Get-Content -Path $pathFile
        if (-not (Test-Path -Path $path)) {
            #Remove-Item -Path $_.FullName -Recurse
            Remove-Location -name $_.Name
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

    $pathDirectory = Join-Path -Path $locationDir -ChildPath (Get-MachineName)
    if (Test-Path -Path $pathDirectory) {
        if ($Debug) {
            Write-Host "Removing path directory '$pathDirectory'" -ForegroundColor Yellow
        }
        Remove-Item -Path $pathDirectory -Recurse
    }

    $subDirCount = (Get-ChildItem -Directory -Path $locationDir).Length
    if ($subDirCount -eq 0) {
        if ($Debug) {
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
        $pathDirectory = Join-Path -Path $_.FullName -ChildPath (Get-MachineName)
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $locPath = Get-Content -Path $pathFile
        if ($path -eq $locPath) {
            Remove-Location -name $_.Name
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
            $pathFile = Join-Path -Path $_.FullName -ChildPath "path.txt"
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
        if ($subAction -eq "add") {
            Get-LocAddHelp
        }
        elseif ($subAction -eq "status") {
            Get-StatusHelp
        }
        elseif ($subAction -eq "note") {
            Get-LocNoteHelp
        }
        elseif ($subAction -eq "notes") {
            Get-LocNotesHelp
        }
        elseif ($subAction -eq "update") {
            Get-LocUpdateHelp
        }
        elseif ($subAction -eq "rename") {
            Get-LocRenameHelp
        }
        elseif ($subAction -eq "edit") {
            Get-LocEditHelp
        }
        elseif ($subAction -eq "list") {
            Get-LocListHelp
        }
        elseif ($subAction -eq "remove") {
            Get-LocRemoveHelp
        }
        elseif ($subAction -eq "remove-this") {
            Get-LocRemoveThisHelp
        }
        elseif ($subAction -eq "repair") {
            Get-LocRepairHelp
        }
        elseif ($subAction -eq "goto") {
            Get-LocGotoHelp
        }
        elseif ($subAction -eq "where") {
            Get-LocWhereHelp
        }
        else {
            Write-Host
            Write-Host "Invalid sub-action '$subAction'" -ForegroundColor Red
            Write-Host "For more help: loc help" -ForegroundColor Red
            Write-Host
        }
    }
    else {
        loc go $action
    }
}

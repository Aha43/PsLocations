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
. $PSScriptRoot/Functions/CliImplementation/WhereIAm.ps1
. $PSScriptRoot/Functions/CliImplementation/Edit.ps1
. $PSScriptRoot/Functions/CliImplementation/Update.ps1
. $PSScriptRoot/Functions/CliImplementation/Rename.ps1
. $PSScriptRoot/Functions/CliImplementation/Remove.ps1
. $PSScriptRoot/Functions/CliImplementation/Repair.ps1

# cli
function Loc {
    if (-not (TestLocationsSystemOk)) {
        exit 1
    }

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
        RenameLocation -name $name -newName $newName
    }
    elseif ($action -eq "edit") {
        if ($args.Length -lt 3) {
            Write-Host "Usage: loc edit <name> <description>" -ForegroundColor Red
            return
        }

        $name = $args[1]
        $description = $args[2]
        EditDescription -name $name -description $description
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
        GetLocationWhereIAm
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

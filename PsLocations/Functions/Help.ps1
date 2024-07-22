function Get-DebugHelp {
    Write-Host
    Write-Host "Usage: loc debug" -ForegroundColor Green
    Write-Host "Switch debug mode on or off" -ForegroundColor Green
    Write-Host
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

function Get-LocShowHelp {
    Write-Host
    Write-Host "Usage: loc show" -ForegroundColor Green
    Write-Host "Show all locations by returning an array of objects representing locations" -ForegroundColor Green
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

function GetLocCliActions {
    $commands = @(
        "add",
        "note",
        "notes",
        "update",
        "rename",
        "edit",
        "list",
        "show",
        "remove",
        "remove-this",
        "repair",
        "goto",
        "where",
        "status",
        "debug"
    )
    return $commands
}

function Get-LocCliHelp {
    $actions = (GetLocCliActions) -join ", "
    Write-Host
    Write-Host "loc - A location management and navigation command line interface" -ForegroundColor Green
    Write-Host
    Write-Host "Usage: loc <action> ..." -ForegroundColor Green
    Write-Host "Actions: $actions" -ForegroundColor Green
    Write-Host
    Write-Host "Use 'loc help <action>' for more information on a specific action" -ForegroundColor Green
    Write-Host
}

function Get-SubActionHelp(
    [string]$action
) {
    switch ($action) {
        "debug" {
            Get-DebugHelp
        }
        "add" {
            Get-LocAddHelp
        }
        "note" {
            Get-LocNoteHelp
        }
        "notes" {
            Get-LocNotesHelp
        }
        "update" {
            Get-LocUpdateHelp
        }
        "rename" {
            Get-LocRenameHelp
        }
        "edit" {
            Get-LocEditHelp
        }
        "list" {
            Get-LocListHelp
        }
        "show" {
            Get-LocShowHelp
        }
        "remove" {
            Get-LocRemoveHelp
        }
        "remove-this" {
            Get-LocRemoveThisHelp
        }
        "repair" {
            Get-LocRepairHelp
        }
        "goto" {
            Get-LocGotoHelp
        }
        "where" {
            Get-LocWhereHelp
        }
        "status" {
            Get-StatusHelp
        }
        default {
            Write-Host
            Write-Host "Invalid sub-action '$subAction'" -ForegroundColor Red
            Write-Host "For more help: loc help" -ForegroundColor Red
            Write-Host
        }
    }
}

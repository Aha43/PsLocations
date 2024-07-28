function GetDebugHelp {
    Write-Host
    Write-Host "Usage: loc debug" -ForegroundColor Green
    Write-Host "Switch debug mode on or off" -ForegroundColor Green
    Write-Host
}

function GetLocAddHelp {
    Write-Host
    Write-Host "Usage: loc add <name | .> <description>" -ForegroundColor Green
    Write-Host "Add the current working directory as a location with the given name and description" -ForegroundColor Green
    Write-Host
}

function GetLocNoteHelp {
    Write-Host
    Write-Host "Usage: loc note <name | . | pos> <note>" -ForegroundColor Green
    Write-Host "Add a note to the location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host
}

function GetLocNotesHelp {
    Write-Host
    Write-Host "Usage: loc notes <name | . | pos>" -ForegroundColor Green
    Write-Host "Show notes for the location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host
}

function GetLocUpdateHelp {
    Write-Host
    Write-Host "Usage: loc update <name | pos>" -ForegroundColor Green
    Write-Host "Update the path of a location with the given name (or position in location list) to the current working directory" -ForegroundColor Green
    Write-Host
}

function GetLocRenameHelp {
    Write-Host
    Write-Host "Usage: loc rename <name | . | pos> <new-name>" -ForegroundColor Green
    Write-Host "Rename a location with the given name or pos (or position in location list) to the new name" -ForegroundColor Green
    Write-Host
}

function GetLocEditHelp {
    Write-Host
    Write-Host "Usage: loc edit <name | . | pos> <description>" -ForegroundColor Green
    Write-Host "Edit the description of a location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host
}

function GetLocListHelp {
    Write-Host
    Write-Host "Usage: loc list" -ForegroundColor Green
    Write-Host "List all locations" -ForegroundColor Green
    Write-Host "You can also use 'loc ls' or 'loc l' to list all locations" -ForegroundColor Green
    Write-Host
}

function GetLocRemoveHelp {
    Write-Host
    Write-Host "Usage: loc remove <name | . | pos>" -ForegroundColor Green
    Write-Host "Remove a location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host
}

function GetLocRepairHelp {
    Write-Host
    Write-Host "Usage: loc repair" -ForegroundColor Green
    Write-Host "Remove locations that do not physically exist" -ForegroundColor Green
    Write-Host
}

function GetLocGotoHelp {
    Write-Host
    Write-Host "Usage: loc goto <name | pos>" -ForegroundColor Green
    Write-Host "Go to the location with the given name (or position in location list)" -ForegroundColor Green
    Write-Host "You can also use 'loc go <name | pos>' to go to a location" -ForegroundColor Green
    Write-Host "Finally, you can use 'loc <name | pos>' to go to a location" -ForegroundColor Green
    Write-Host
}

function GetLocWhereHelp {
    Write-Host
    Write-Host "Usage: loc where" -ForegroundColor Green
    Write-Host "Show the location you are currently at" -ForegroundColor Green
    Write-Host
}

function GetStatusHelp {
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
        "remove",
        "repair",
        "goto",
        "where",
        "status",
        "debug"
    )
    return $commands
}

function GetLocCliHelp {
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

function GetSubActionHelp(
    [string]$action
) {
    switch ($action) {
        "debug" {
            GetDebugHelp
        }
        "add" {
            GetLocAddHelp
        }
        "note" {
            GetLocNoteHelp
        }
        "notes" {
            GetLocNotesHelp
        }
        "update" {
            GetLocUpdateHelp
        }
        "rename" {
            GetLocRenameHelp
        }
        "edit" {
            GetLocEditHelp
        }
        "list" {
            GetLocListHelp
        }
        "remove" {
            GetLocRemoveHelp
        }
        "repair" {
            GetLocRepairHelp
        }
        "goto" {
            GetLocGotoHelp
        }
        "where" {
            GetLocWhereHelp
        }
        "status" {
            GetStatusHelp
        }
        default {
            Write-Host
            Write-Host "Invalid sub-action '$subAction'" -ForegroundColor Red
            Write-Host "For more help: loc help" -ForegroundColor Red
            Write-Host
        }
    }
}

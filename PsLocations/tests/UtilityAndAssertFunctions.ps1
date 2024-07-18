
# Utility functions

function Get-TheMachineName {
    $retVal = $env:COMPUTERNAME
    if (-not $retVal) {
        $retVal = $(hostname)
    }
    return $retVal
}

# Asserts functions

function Test-LocationShouldExistAsExpected {
    param(
        [string]$locationsDir, # the directory where the locations are stored
        [string]$name, # the name of the location
        [string]$locationPath # the path of the location beeing bookmarked
    )

    $bookmarkDir = Join-Path -Path $locationsDir -ChildPath $name
    $bookmarkDir | Should -Exist

    $descriptionFile = Join-Path -Path $bookmarkDir -ChildPath "description.txt"
    $descriptionFile | Should -Exist
    $description = Get-Content -Path $descriptionFile
    $description | Should -Be "Test location"

    $machineName = Get-TheMachineName
    $bookmarkPathDir = Join-Path -Path $bookmarkDir -ChildPath $machineName
    $bookmarkPathDir | Should -Exist

    $bookmarkPathFile = Join-Path -Path $bookmarkPathDir -ChildPath "path.txt"
    $bookmarkPathFile | Should -Exist
    $bookmarkPath = Get-Content -Path $bookmarkPathFile
    $bookmarkPath | Should -Be $locationPath
}

function Test-LocationShouldNotExist {
    param(
        [string]$locationsDir, # the directory where the locations are stored
        [string]$name # the name of the location
    )

    $bookmarkDir = Join-Path -Path $locationsDir -ChildPath $name
    $bookmarkDir | Should -Not -Exist
}

function Test-NoteShouldExistForLocation {
    param (
        [string]$locationsDir, # the directory where the locations are stored
        [string]$name, # the name of the location
        [string]$note # the note to be checked
    )
    
    $bookmarkDir = Join-Path -Path $locationsDir -ChildPath $name
    $noteFile = Join-Path -Path $bookmarkDir -ChildPath "note.txt"
    $noteFile | Should -Exist
    $noteContent = Get-Content -Path $noteFile
    $noteContent | Should -Be $note
}

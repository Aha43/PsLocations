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
        [string]$description, # the description of the location
        [string]$locationPath # the path of the location beeing bookmarked
    )

    $bookmarkDir = Join-Path -Path $locationsDir -ChildPath $name
    $bookmarkDir | Should -Exist

    $descriptionFile = Join-Path -Path $bookmarkDir -ChildPath "description.txt"
    $descriptionFile | Should -Exist
    $description = Get-Content -Path $descriptionFile
    $description | Should -Be $description

    $machineName = Get-TheMachineName
    $bookmarkMachinesDir = Join-Path -Path $bookmarkDir -ChildPath "machines"
    $bookmarkPathDir = Join-Path -Path $bookmarkMachinesDir -ChildPath $machineName
    $bookmarkPathDir | Should -Exist

    $bookmarkPathFile = Join-Path -Path $bookmarkPathDir -ChildPath "path.txt"
    $bookmarkPathFile | Should -Exist
    $bookmarkPath = Get-Content -Path $bookmarkPathFile
    $bookmarkPath | Should -Be $locationPath
}

function Test-LocationShouldListAsExpected {
    param(
        [string]$name, # the name of the location
        [string]$description, # the path of the location beeing bookmarked
        [string]$locationPath # the path of the location beeing bookmarked
    )

    $list = (loc show)
    $list | Should -Not -Be $null
    $list
    $location = $list | Where-Object { $_.Name -eq $name }
    $location | Should -Not -Be $null
    $location.Name | Should -Be $name
    $location.Description | Should -Be $description
    $location.Path | Should -Be $locationPath
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
        [string]$note, # the note to be checked
        [string]$noteFile # the note file to be checked
    )

    $bookmarkDir = Join-Path -Path $locationsDir -ChildPath $name
    $notesDir = Join-Path -Path $bookmarkDir -ChildPath "notes"
    $notesDir | Should -Exist

    $noteFile | Should -Exist
    $noteContent = Get-Content -Path $noteFile
    $noteContent | Should -Be $note
}

function Test-LastNoteShouldListAsExpected {
    param(
        [string]$name, # the name of the location
        [string]$note, # the note to be checked
        [string]$timeStamp # the timestamp of the note
    )

    $list = (loc notes $name)
    $list | Should -Not -Be $null
    $list
    $lastNote = $list | Where-Object { $_.Timestamp -eq $timeStamp }
    $lastNote | Should -Not -Be $null
    $lastNote.Content | Should -Be $note
}

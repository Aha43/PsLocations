function GetNextNoteFile {
    param(
        [string]$name
    )
    $notesDir = GetNotesDir -name $name
    if (-not $notesDir) {
        return $null
    }

    $timeStamp = Get-Timestamp
    $noteFile = Join-Path -Path $notesDir -ChildPath "$timeStamp.txt"
    return $noteFile
}

function AddLocationNote {
    param(
        [string]$name,
        [string]$note
    )

    $noteFile = GetNextNoteFile -name $name
    if (-not $noteFile) {
        return
    }

    $note | Out-File -FilePath $noteFile

    return [PSCustomObject]@{
        Timestamp = [System.IO.Path]::GetFileNameWithoutExtension($noteFile)
        Location = $name
        File = $noteFile
        Content = $note
    }
}

function ShowNotes {
    param(
        [string]$name
    )

    $notesDir = GetNotesDir -name $name
    if (-not $notesDir) {
        return
    }

    $retVal = @()

    $notes = Get-ChildItem -Path $notesDir
    $notes | ForEach-Object {
        $fullName = $_.FullName
        $noteContent = Get-Content -Path $fullName
        $noteTimestamp = [System.IO.Path]::GetFileNameWithoutExtension($fullName)
        $note = [PSCustomObject]@{
            Timestamp = $noteTimestamp
            Content = $noteContent
        }

        $retVal += $note
    }

    return $retVal
}

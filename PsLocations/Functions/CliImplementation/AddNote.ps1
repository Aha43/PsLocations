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

    if (-not (TestLocationsSystemOk)) {
        return
    }

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
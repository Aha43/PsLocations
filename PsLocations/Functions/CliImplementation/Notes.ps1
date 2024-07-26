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
        return [PSCustomObject]@{
            Ok = $false
            Error = "Location '$name' does not exist: Did not find notes directory"
            Timestamp = $null
            Location = $name
            File = $null
            Content = $note
        }
    }

    $note | Out-File -FilePath $noteFile

    return [PSCustomObject]@{
        Ok = $true
        Error = $null
        Timestamp = [System.IO.Path]::GetFileNameWithoutExtension($noteFile)
        Location = $name
        File = $noteFile
        Content = $note
    }
}

function ListNotes {
    param(
        [string]$name
    )

    $data = ShowNotes -name $name
    if ($data.Ok) {
        return $data.Notes
    }
    else {
        Write-Host $data.Error -ForegroundColor Red
        return $null
    }
}

function GetNotes {
    param(
        [string]$name
    )

    $noteList = @()

    $notesDir = GetNotesDir -name $name
    if (-not $notesDir) {
        return [PSCustomObject]@{
            Ok = $false
            Error = "Location '$name' does not exist: Did not find notes directory"
            Location = $name
            Notes = $noteList
        }
        Write-Host $err -ForegroundColor Red
    }

    $notes = Get-ChildItem -Path $notesDir
    $notes | ForEach-Object {
        $fullName = $_.FullName
        $noteContent = Get-Content -Path $fullName
        $noteTimestamp = [System.IO.Path]::GetFileNameWithoutExtension($fullName)
        $note = [PSCustomObject]@{
            Timestamp = $noteTimestamp
            Content = $noteContent
        }

        $noteList += $note
    }

    return [PSCustomObject]@{
        Ok = $true
        Error = $null
        Location = $name
        Notes = $noteList
    }
}

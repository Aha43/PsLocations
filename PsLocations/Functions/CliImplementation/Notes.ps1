function GetNextNoteFile {
    param(
        [string]$name
    )
    $notesDir = GetNotesDir -name $name
    if (-not $notesDir.Ok) {
        return [PSCustomObject]@{
            Ok = $false
            Error = $notesDir.Error
            File = $null
        }
    }

    $timeStamp = Get-Timestamp
    $noteFile = Join-Path -Path $notesDir -ChildPath "$timeStamp.txt"
    return [PSCustomObject]@{
        Ok = $true
        Error = $null
        File = $noteFile
    }
}

function AddLocationNote {
    param(
        [string]$name,
        [string]$note
    )

    $noteFileData = GetNextNoteFile -name $name
    if (-not $noteFile.Ok) {
        return [PSCustomObject]@{
            Ok = $false
            Error = $noteFileData.Error
            Timestamp = $null
            Location = $name
            File = $null
            Content = $note
        }
    }

    $note | Out-File -FilePath $noteFileData.File

    return [PSCustomObject]@{
        Ok = $true
        Error = $null
        Timestamp = [System.IO.Path]::GetFileNameWithoutExtension($noteFile)
        Location = $name
        File = $noteFileData.File
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
    if (-not $notesDir.Ok) {
        return [PSCustomObject]@{
            Ok = $false
            Error = $notesDir.Error
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

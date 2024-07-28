function GetNextNoteFile {
    param(
        [string]$name
    )
    $notesDirData = GetNotesDir -name $name
    if (-not $notesDirData.Ok) {
        return [PSCustomObject]@{
            Ok = $false
            Error = $notesDirData.Error
            File = $null
            Name = $null
        }
    }

    $timeStamp = Get-Timestamp
    $noteFile = Join-Path -Path $notesDirData.NotesDir -ChildPath "$timeStamp.txt"
    while (Test-Path -Path $noteFile) {
        # wating for 1 second
        Start-Sleep -Seconds 1
        $timeStamp = Get-Timestamp
        $noteFile = Join-Path -Path $notesDirData.NotesDir -ChildPath "$timeStamp.txt"

    }
    return [PSCustomObject]@{
        Ok = $true
        Error = $null
        File = $noteFile
        Name = $notesDirData.Name
    }
}

function AddLocationNote {
    param(
        [string]$name,
        [string]$note
    )

    $noteFileData = GetNextNoteFile -name $name
    if (-not $noteFileData.Ok) {
        Write-Host GRR
        return [PSCustomObject]@{
            Ok = $false
            Error = $noteFileData.Error
            Timestamp = $null
            Location = $noteFileData.Name
            File = $null
            Content = $note
        }
    }

    $note | Out-File -FilePath $noteFileData.File

    return [PSCustomObject]@{
        Ok = $true
        Error = $null
        Timestamp = [System.IO.Path]::GetFileNameWithoutExtension($noteFileData.File)
        Location = $noteFileData.Name
        File = $noteFileData.File
        Content = $note
    }
}

function ListNotes {
    param(
        [string]$name
    )

    $data = GetNotes -name $name
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

    $notesDirData = GetNotesDir -name $name
    if (-not $notesDirData.Ok) {
        return [PSCustomObject]@{
            Ok = $false
            Error = $notesDirData.Error
            Location = $notesDirData.Name
            Notes = $noteList
        }
        Write-Host $err -ForegroundColor Red
    }

    $notes = Get-ChildItem -Path $notesDirData.NotesDir
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
        Name = $notesDirData.Name
    }
}

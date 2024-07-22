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

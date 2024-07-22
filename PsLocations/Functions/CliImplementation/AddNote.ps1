function AddLocationNote {
    param(
        [string]$name,
        [string]$note
    )

    if (-not (TestLocationsSystemOk)) {
        return
    }

    $noteFile = Get-NextNoteFile -name $name
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
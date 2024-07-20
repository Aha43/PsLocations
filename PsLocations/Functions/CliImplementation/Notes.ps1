function Show-Notes {
    param(
        [string]$name
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $notesDir = Get-NotesDir -name $name
    if (-not $notesDir) {
        return
    }

    $notes = Get-ChildItem -Path $notesDir
    $notes | ForEach-Object {
        $fullName = $_.FullName
        $note = Get-Content -Path $fullName
        $noteTimestamp = [System.IO.Path]::GetFileNameWithoutExtension($fullName)
        Write-Host ($noteTimestamp + " - " + $note) -ForegroundColor Cyan
    }
}
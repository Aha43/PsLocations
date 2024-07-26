function EditDescription {
    param(
        [string]$name,
        [string]$description
    )

    $debug = GetDebug

    $location = (LookupLocationDir -nameOrPos $name -reportError:$true)
    if (-not $location.Ok) {
        return [PSCustomObject]@{
            Ok = $false
            Error = $location.Error
        }
    }

    if ($debug) {
        Write-Host "Editing description for location '$name'" -ForegroundColor Yellow
        Write-Host "Location directory: $($location.LocationDir)" -ForegroundColor Yellow
    }

    if (Test-Path -Path $location.LocationDir) {
        $descFile = Join-Path -Path $location.LocationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile
        return [PSCustomObject]@{
            Ok = $true
            Error = $null
        }
    }
    else {
        return [PSCustomObject]@{
            Ok = $false
            Error = "Location path '$location.LocationDir' does not exist"
        }
    }
}

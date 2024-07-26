function UpdateLocationPath {
    param(
        [string]$name
    )

    if ($name -eq ".") {
        return [PSCustomObject]@{
            Ok = $false
            Error = ". syntax not supported"
        }
    }

    $location = (LookupLocationDir -nameOrPos $name)
    if (-not $location.Ok) {
        return [PSCustomObject]@{
            Ok = $false
            Error = $location.Error
        }
    }

    if (Test-Path -Path $location.LocationDir) {
        $pathDirectory = GetPathDirectory -name $location.Name
        if (-not (Test-Path -Path $pathDirectory)) {
            [void](New-Item -Path $pathDirectory -ItemType Directory)
        }
        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"

        $path = (get-location).Path
        $path | Out-File -FilePath $pathFile

        return [PSCustomObject]@{
            Ok = $true
            Error = $null
        }
    }
    else {
        return [PSCustomObject]@{
            Ok = $false
            Error = "Location '$name' does not exist"
        }
    }
}

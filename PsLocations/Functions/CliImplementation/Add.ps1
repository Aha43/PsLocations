function AddLocation {
    param(
        [string]$name,
        [string]$description
    )

    if (-not (Test-LocationsSystemOk)) {
        return
    }

    $name = Get-LocationName -name $name

    $locationDir = Get-LocationDirectory -name $name
    if (-not (Test-Path -Path $locationDir)) {
        if (GetDebug) {
            Write-Host "Creates location directory '$locationDir'" -ForegroundColor Yellow
        }
        [void](New-Item -Path $locationDir -ItemType Directory)

        $machinesDirectory = Get-MachinesDirectory -name $name
        if (GetDebug) {
            Write-Host "Creates machines directory '$machinesDirectory'" -ForegroundColor Yellow
        }
        [void](New-Item -Path $machinesDirectory -ItemType Directory)

        $pathDirectory = Get-PathDirectory -name $name
        if (GetDebug) {
            Write-Host "Creates path directory '$pathDirectory'" -ForegroundColor Yellow
        }
        [void](New-Item -Path $pathDirectory -ItemType Directory)

        $pathFile = Join-Path -Path $pathDirectory -ChildPath "path.txt"
        $location = (Get-Location).Path
        $location | Out-File -FilePath $pathFile

        $descFile = Join-Path -Path $locationDir -ChildPath "description.txt"
        $description | Out-File -FilePath $descFile
    }
    else {
        if (GetDebug) {
            Write-Host "'$locationDir' do exists" -ForegroundColor Yellow
        }
        Write-Host "Location named '$name' already added" -ForegroundColor Red
        Write-Host "Use 'loc update $name' to update the path or add for the machine you are on" -ForegroundColor Green
    }
}

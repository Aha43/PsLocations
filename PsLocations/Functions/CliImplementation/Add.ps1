function AddLocation {
    param(
        [string]$name,
        [string]$description
    )

    $debug = GetDebug
    $writeUser = GetWriteUser

    $name = Get-LocationName -name $name

    $locationDir = GetLocationDirectory -name $name
    if (-not (Test-Path -Path $locationDir)) {
        if ($debug) {
            Write-Host "Creates location directory '$locationDir'" -ForegroundColor Yellow
        }
        [void](New-Item -Path $locationDir -ItemType Directory)

        $machinesDirectory = GetMachinesDirectory -name $name
        if ($debug) {
            Write-Host "Creates machines directory '$machinesDirectory'" -ForegroundColor Yellow
        }
        [void](New-Item -Path $machinesDirectory -ItemType Directory)

        $pathDirectory = GetPathDirectory -name $name
        if ($debug) {
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
        if ($debug) {
            Write-Host "'$locationDir' do exists" -ForegroundColor Yellow
        }
        if ($writeUser) {
            Write-Host "Location named '$name' already added" -ForegroundColor Red
            Write-Host "Use 'loc update $name' to update the path or add for the machine you are on" -ForegroundColor Green
        }
    }
}

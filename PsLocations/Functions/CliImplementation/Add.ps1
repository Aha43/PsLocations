function AddLocation {
    param(
        [string]$name,
        [string]$description
    )
    $debug = GetDebug

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

        return [PSCustomObject]@{
            Ok = $true
            Error = $null
        }
    }
    else {
        if ($debug) {
            Write-Host "'$locationDir' do exists" -ForegroundColor Yellow
        }
        return [PSCustomObject]@{
            Ok = $false
            Error = "Location '$name' already exists"
        }
    }
}

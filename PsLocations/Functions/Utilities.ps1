function Test-ValidDirectoryName {
    param (
        [string]$DirectoryName
    )

    # Regex patterns for invalid characters
    $invalidCharsWindows = '[<>:"/\\|?*\x00-\x1F]'
    $invalidCharsMacLinux = '[:\x00]'

    # Combined invalid characters for all platforms
    $combinedInvalidChars = "$invalidCharsWindows|$invalidCharsMacLinux"

    # Check for invalid characters
    if ($DirectoryName -match $combinedInvalidChars) {
        return $false
    }

    # Additional common checks
    if ($DirectoryName.Trim() -eq "") {
        return $false
    }
    if ($DirectoryName.Length -gt 255) {
        return $false
    }

    return $true
}

function Get-MachineName {
    $retVal = $env:COMPUTERNAME
    if (-not $retVal) {
        $retVal = $(hostname)
    }

    if ($env:LOC_MACHINE_NAME) {
        $retVal = $env:LOC_MACHINE_NAME
    }

    if (-not (Test-ValidDirectoryName -DirectoryName $retVal)) {
        $errMsg = "Invalid computer name $retVal since can not be used as a directory name"
        Write-Host $errMsg -ForegroundColor Red
        Write-Host "Please set the COMPUTERNAME environment variable to a valid directory name" -ForegroundColor Red
        throw $errMsg
    }

    return $retVal
}

function Convert-ToUnsignedInt {
    param (
        [string]$inputString
    )

    # Try to convert the input string to an integer
    [int]$number = 0
    if (-not [int]::TryParse($inputString, [ref]$number)) {
        return -1
    }

    # Check if the number is negative
    if ($number -lt 0) {
        return -1
    }

    return [uint32]$number
}

function Get-Timestamp {
    return (Get-Date).ToString("yyyyMMddHHmmss")
}

function Test-ValidLocationName {
    param (
        [string]$identifier
    )

    $regex = '^[a-zA-Z_][a-zA-Z0-9_]*$'

    if ($identifier -match $regex) {
        return $true
    } else {
        return $false
    }
}

function Get-LocationName {
    param (
        [string]$name
    )

    if ($name -eq ".") {
        $name = (Get-Location).Path | Split-Path -Leaf
    }

    if (-not (Test-ValidLocationName -identifier $name)) {
        $errMsg = "Invalid location name $name"
        Write-Host $errMsg -ForegroundColor Red
        throw $errMsg
    }

    return $name
}

function GetLocationsDirectory2 {
    $retVal = Join-Path -Path $HOME -ChildPath ".locations"

    if ($env:LocHome) {
        $retVal = $env:LocHome
    }

    if (-not (Test-Path -Path $retVal)) {
        [void](New-Item -Path $retVal -ItemType Directory)
    }

    return $retVal
}

function RemoveDirSafely {
    param (
        [bool]$debug,
        [string]$function,
        [string]$dir
    )

    if ($debug) {
        Write-Host "Function $function : Remove-DirSafely: $dir" -ForegroundColor Yellow
    }

    $locationsDir = GetLocationsDirectory2
    if ($dir -eq $locationsDir) {
        $errMsg = "Can not remove the locations directory"
        Write-Host $errMsg -ForegroundColor Red
        throw $errMsg
    }

    # if not descendant of locations dir
    if (-not $dir.StartsWith($locationsDir)) {
        $errMsg = "Can not remove directory $dir since it is not a descendant of the locations directory"
        Write-Host $errMsg -ForegroundColor Red
        throw $errMsg
    }

    if (Test-Path -Path $dir) {
        Remove-Item -Path $dir -Recurse -Force
    }
}

function GetMachineNamesForLocation {
    param (
        [string]$name
    )

    $debug = GetDebug

    $machinesDirectory = GetMachinesDirectory -name $name
    if ($debug) {
        Write-Host "Get-MachineNamesForLocation: Checking path directory '$machinesDirectory'" -ForegroundColor Yellow
    }

    $machineNames = @()
    if (Test-Path -Path $machinesDirectory) {
        $machineNames = Get-ChildItem -Path $machinesDirectory -Directory | ForEach-Object {
            $_.Name
        }
    }
    return $machineNames
}

function GetLocationNameAtPosition {
    param (
        [int]$position
    )

    $locationsDir = GetLocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    if ($locations.Length -gt 0) {
        $index = 0
        foreach ($location in $locations) {
            if ($index -eq $position) {
                return $location.Name
            }
            $index++
        }
    }
    return $null
}

function GetLocationCount {
    $locationsDir = GetLocationsDirectory
    $locations = Get-ChildItem -Path $locationsDir
    return $locations.Length
}

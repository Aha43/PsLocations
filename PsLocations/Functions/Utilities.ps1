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

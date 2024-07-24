$BuildNumberFile = Join-Path -Path $PSScriptRoot -ChildPath ".."
$BuildNumberFile = Join-Path -Path $BuildNumberFile -ChildPath "PsLocations"
$BuildNumberFile = Join-Path -Path $BuildNumberFile -ChildPath "build.txt"

# Check if the build number file exists
if (Test-Path $BuildNumberFile) {
    # Read the current build number
    $buildNumber = Get-Content -Path $BuildNumberFile -Raw
    $buildNumber = [int]$buildNumber + 1
} else {
    # If the file does not exist, start the build number at 1
    $buildNumber = 1
}

# Write the new build number back to the file
Set-Content -Path $BuildNumberFile -Value $buildNumber

# Output the new build number
Write-Output $buildNumber

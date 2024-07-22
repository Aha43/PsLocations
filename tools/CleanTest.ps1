# Function to delete all testResults.xml files in the given directory and subdirectories
function DeleteTestResultsFiles {
    param (
        [string]$Path = "."
    )

    try {
        # Get all testResults.xml files in the specified directory and subdirectories
        $files = Get-ChildItem -Path $Path -Recurse -Filter "testResults.xml"

        # Check if any files were found
        if ($files.Count -eq 0) {
            Write-Host "No testResults.xml files found in $Path" -ForegroundColor Yellow
        } else {
            # Delete each found file
            foreach ($file in $files) {
                Remove-Item -Path $file.FullName -Force
                Write-Host "Deleted: $($file.FullName)" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
}

# Call the function with the current directory as the default path
DeleteTestResultsFiles -Path "."

$testDirPath = "./PsLocations/tests/TestAreas"
if (Test-Path -Path $testDirPath) {
    Write-Host "Removing test directory: $testDirPath"
    Remove-Item -Path $testDirPath -Recurse -Force
}
else {
    Write-Host "Test directory not found: $testDirPath"
}
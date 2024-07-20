$testResultFile = "./testResults.xml"
if (Test-Path -Path $testResultFile) {
    Write-Host "Removing test result file: $testResultFile"
    Remove-Item -Path $testResultFile -Force
}
else {
    Write-Host "Test result file not found: $testResultFile"
}

$testDirPath = "./PsLocations/tests/TestDir"
if (Test-Path -Path $testDirPath) {
    Write-Host "Removing test directory: $testDirPath"
    Remove-Item -Path $testDirPath -Recurse -Force
}
else {
    Write-Host "Test directory not found: $testDirPath"
}
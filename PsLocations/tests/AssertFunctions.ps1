function Test-LocationShouldExistAsExpected {
    param(
        [string]$locationDir,
        [string]$name
    )

    $bookmarkDir = Join-Path -Path $locationDir -ChildPath $name
    $bookmarkDir | Should -Exist

    $descriptionFile = Join-Path -Path $bookmarkDir -ChildPath "description.txt"
    $descriptionFile | Should -Exist
    $description = Get-Content -Path $descriptionFile
    $description | Should -Be "Test location"

    $machineName = Get-TheMachineName
    $bookmarkPathDir = Join-Path -Path $bookmarkDir -ChildPath $machineName
    $bookmarkPathDir | Should -Exist

    $bookmarkPathFile = Join-Path -Path $bookmarkPathDir -ChildPath "path.txt"
    $bookmarkPathFile | Should -Exist
    $bookmarkPath = Get-Content -Path $bookmarkPathFile
    $bookmarkPath | Should -Be $locPath
}

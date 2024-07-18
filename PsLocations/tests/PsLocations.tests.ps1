

#. "./AssertFunctions.ps1"


# utility functions


Describe "PsLocations tests" {

    BeforeAll {
        . $PSScriptRoot/UtilityAndAssertFunctions.ps1   

        $here = $PSScriptRoot
        $testLocDir = Join-Path -Path $here -ChildPath "TestLocations"
        $testDir = Join-Path -Path $here -ChildPath "TestDir"
        New-Item -ItemType Directory -Path $testDir

        # Import the module once before all tests
        Import-Module -Name "$here/../PsLocations.psm1"
        $env:LocHome = $testLocDir

        if (Test-Path -Path $testLocDir) {
            Remove-Item -Path $testLocDir -Recurse -Force
        }
    }

    AfterAll {
        if (Test-Path -Path $testDir) {
            Remove-Item -Path $testDir -Recurse -Force
        }
        if (Test-Path -Path $testLocDir) {
            Remove-Item -Path $testLocDir -Recurse -Force
        }

        # Remove the module after all tests
        Remove-Module -Name "PsLocations"

        # Remove the environment variable
        Remove-Item -Path "env:LocHome"
    }

    It "loc status should create the testLocDir" {
        loc status

        $testLocDir | Should -Exist
    }

    It "loc add should create a new location" {
        # arrange
        $locName = "testLoc"
        $locPath = Join-Path -Path $testDir -ChildPath $locName
        New-Item -ItemType Directory -Path $locPath
        Push-Location -Path $locPath

        # act
        loc Add "Test" "Test location"

        # assert
        Pop-Location

        #$bookmarkDir = Join-Path -Path $testLocDir -ChildPath "Test"
        #$bookmarkDir | Should -Exist
        Test-LocationShouldExistAsExpected -locationDir $testLocDir -name "Test"

        # $descriptionFile = Join-Path -Path $bookmarkDir -ChildPath "description.txt"
        # $descriptionFile | Should -Exist
        # $description = Get-Content -Path $descriptionFile
        # $description | Should -Be "Test location"

        # $machineName = Get-TheMachineName
        # $bookmarkPathDir = Join-Path -Path $bookmarkDir -ChildPath $machineName
        # $bookmarkPathDir | Should -Exist

        # $bookmarkPathFile = Join-Path -Path $bookmarkPathDir -ChildPath "path.txt"
        # $bookmarkPathFile | Should -Exist
        # $bookmarkPath = Get-Content -Path $bookmarkPathFile
        # $bookmarkPath | Should -Be $locPath
    }   

}

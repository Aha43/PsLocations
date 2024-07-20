Describe "PsLocations tests" {

    BeforeAll {
        . $PSScriptRoot/UtilityAndAssertFunctions.ps1   

        $here = $PSScriptRoot
        $testLocationsDir = Join-Path -Path $here -ChildPath "TestLocations"
        $testDir = Join-Path -Path $here -ChildPath "TestDir"
        New-Item -ItemType Directory -Path $testDir

        # Import the module once before all tests
        Import-Module -Name "$here/../PsLocations.psm1"
        $env:LocHome = $testLocationsDir

        if (Test-Path -Path $testLocationsDir) {
            Remove-Item -Path $testLocationsDir -Recurse -Force
        }
    }

    AfterAll {
        $here = $PSScriptRoot
        $testLocationsDir = Join-Path -Path $here -ChildPath "TestLocations"
        $testDir = Join-Path -Path $here -ChildPath "TestDir"

        if (Test-Path -Path $testDir) {
            Remove-Item -Path $testDir -Recurse -Force
        }
        if (Test-Path -Path $testLocationsDir) {
            Remove-Item -Path $testLocationsDir -Recurse -Force
        }

        # Remove the module after all tests
        Remove-Module -Name "PsLocations"

        # Remove the environment variable
        if ($env:LocHome) {
            Remove-Item -Path "env:LocHome"
        }
    }

    It "loc status should create the testLocDir" {
        loc status

        $testLocationsDir | Should -Exist
    }

    It "loc should be able to create a new location, make notes and navigate and remove it" {
        # arrange
        $locName = "testLoc"
        $locPath = Join-Path -Path $testDir -ChildPath $locName
        New-Item -ItemType Directory -Path $locPath
        Push-Location -Path $locPath

        # Test adding location
            # act: add the location
            loc Add "Test" "Test location"

            Test-LocationShouldListAsExpected -name "Test" -locationPath $locPath

            # assert file structure reflects the new location
            Pop-Location
            Test-LocationShouldExistAsExpected -locationsDir $testLocationsDir -name "Test" -locationPath $locPath
        

        # Test adding note
            # act: add a note to the location
            loc Note "Test" "Test note"

            # assert
            Test-NoteShouldExistForLocation -locationsDir $testLocationsDir -name "Test" -note "Test note"

        # Test the navigation
            # act: navigate to the location
            loc Test

            # assert: we should be in the location
            $pwd.Path | Should -Be $locPath
            Set-Location -Path $PSScriptRoot

            # act: navigate to the location using the go
            loc go Test
            # assert: we should be in the location
            $pwd.Path | Should -Be $locPath
            Set-Location -Path $PSScriptRoot

            # act: navigate to the location using the goto
            loc goto Test
            # assert: we should be in the location
            $pwd.Path | Should -Be $locPath
            Set-Location -Path $PSScriptRoot

        # act: remove the location
            loc Remove "Test"
            # assert the location should not exist
            Test-LocationShouldNotExist -locationsDir $testLocationsDir -name "Test"
    }   

}

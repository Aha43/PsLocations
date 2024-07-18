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
        if (Test-Path -Path $testDir) {
            Remove-Item -Path $testDir -Recurse -Force
        }
        if (Test-Path -Path $testLocationsDir) {
            Remove-Item -Path $testLocationsDir -Recurse -Force
        }

        # Remove the module after all tests
        Remove-Module -Name "PsLocations"

        # Remove the environment variable
        Remove-Item -Path "env:LocHome"
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

        # act: add the location
        loc Add "Test" "Test location"

        # assert
        Pop-Location

        Test-LocationShouldExistAsExpected -locationsDir $testLocationsDir -name "Test" -locationPath $locPath
        
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

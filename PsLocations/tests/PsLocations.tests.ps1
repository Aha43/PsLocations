Describe "PsLocations tests" {

    BeforeAll {
        . $PSScriptRoot/UtilityAndAssertFunctions.ps1

        $here = $PSScriptRoot
        Set-Location -Path $here

        $testAreasDir = Join-Path -Path $here -ChildPath "TestAreas"
        $testLocationsDir = Join-Path -Path $testAreasDir -ChildPath "TestLocations"

        $testDir = Join-Path -Path $testAreasDir -ChildPath "TestDir"
        New-Item -ItemType Directory -Path $testDir

        # Import the module once before all tests
        Import-Module -Name "$here/../PsLocations.psm1"
        $env:LocHome = $testLocationsDir

        $env:LocWriteUser = 'False'

        if (Test-Path -Path $testAreasDir) {
            Remove-Item -Path $testAreasDir -Recurse -Force
        }
    }

    AfterAll {
        $here = $PSScriptRoot
        Set-Location -Path $here

        $testAreasDir = Join-Path -Path $here -ChildPath "TestAreas"

        if (Test-Path -Path $testAreasDir) {
            Remove-Item -Path $testAreasDir -Recurse -Force
        }

        # Remove the module after all tests
        Remove-Module -Name "PsLocations"

        # Remove the environment variables
        if ($env:LocHome) {
            Remove-Item -Path "env:LocHome"
        }
        if ($env:LocWriteUser) {
            Remove-Item -Path "env:LocWriteUser"
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

            Test-LocationShouldListAsExpected -name "Test" -description "Test location" -locationPath $locPath

            # assert file structure reflects the new location
            Pop-Location
            Test-LocationShouldExistAsExpected -locationsDir $testLocationsDir -name "Test" -description "Test location" -locationPath $locPath

        # Test adding note
            # act: add a note to the location
            $note = (loc Note "Test" "Test note")

            # assert
            $note.Timestamp | Should -Not -BeNullOrEmpty
            $note.Location | Should -Be "Test"
            $note.Content | Should -Be "Test note"
            $note.File | Should -Exist

            Test-NoteShouldExistForLocation -locationsDir $testLocationsDir -name "Test" -note "Test note" -noteFile $note.File
            Test-LastNoteShouldListAsExpected -name "Test" -note "Test note" -timeStamp $note.Timestamp

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

            # act: get where we are in a location
            $whereIAm = loc where
            # assert: we should get the location
            $whereIAm | Should -Not -BeNullOrEmpty
            $whereIAm.Location | Should -Be "Test"
            $whereIAm.Description | Should -Be "Test location"

        # act: get where we are not in a location
            Set-Location -Path $PSScriptRoot
            $whereIAm = loc where
            # assert: we should not get any location
            $whereIAm | Should -BeNullOrEmpty

        # act: Change the description
            # act: change the description
            loc Edit "Test" "New description"
            # assert: the description should be changed
            Test-LocationShouldListAsExpected -name "Test" -description "New description" -locationPath $locPath

        # act: Rename the location
            # act: rename the location
            loc Rename "Test" "NewTest"
            # assert: the location should be renamed
            Test-LocationShouldListAsExpected -name "NewTest" -description "New description" -locationPath $locPath

        # act: remove the location
            $removed = loc Remove "NewTest"
            # assert: the location should be removed
            $removed | Should -Be $true
            # assert: the location should not exist
            Test-LocationShouldNotExist -locationsDir $testLocationsDir -name "Test"
    }

}

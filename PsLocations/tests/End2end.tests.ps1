Describe "PsLocations end to end tests" {
    BeforeAll {
        $here = $PSScriptRoot

        # Import the module once before all tests
        Import-Module -Name "$here/../PsLocations.psm1"

        Set-Location -Path $here

        $e2eTestDir = Join-Path -Path $here -ChildPath "E2e_Test_Directory"
        if (Test-Path -Path $e2eTestDir) {
            Remove-Item -Path $e2eTestDir -Recurse -Force
        }

        New-Item -ItemType Directory -Path $e2eTestDir

        $testLocationsDir = Join-Path -Path $e2eTestDir -ChildPath "TestLocations"

        $env:LocHome = $testLocationsDir
        $env:LocWriteUser = 'False'
    }

    AfterAll {
        $here = $PSScriptRoot

        # Remove the module after all tests
        Remove-Module -Name "PsLocations"

        Set-Location -Path $here

        # Remove the environment variables
        if ($env:LocHome) {
            Remove-Item -Path "env:LocHome"
        }
        if ($env:LocWriteUser) {
            Remove-Item -Path "env:LocWriteUser"
        }
    }

    It "End to end test" {

        #arrange:
        $computer = $env:COMPUTERNAME
        if (-not $computer) {
            $computer = $(hostname)
        }

        #covers 4 in the e2e-tests.md document
        #act:
        $statusData = loc status
        #assert:
        $statusData | Should -Not -BeNullOrEmpty
        $statusData.LocationCount | Should -Be 0
        $statusData.Version | Should -Not -BeNullOrEmpty
        $statusData.Build | Should -Not -BeNullOrEmpty
        $statusData.ComputerName | Should -Not -BeNullOrEmpty
        $statusData.ComputerName | Should -Be $computer
        $statusData.LocationsDirectory | Should -Not -BeNullOrEmpty
        $statusData.LocationsDirectory | Should -Be $testLocationsDir

        #covers 5 and 6 in the e2e-tests.md document
        #arrange:
        $Loc1Dir = Join-Path -Path $e2eTestDir -ChildPath "Loc1"
        $testLoc1Fsi = New-Item -ItemType Directory -Path $Loc1Dir
        Set-Location -Path $Loc1Dir
        #act:
        $retVal = loc add . 'Location 1'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 1
        $locationList[0].Name | Should -Be $testLoc1Fsi.Name
        $locationList[0].Path | Should -Be $testLoc1Fsi.FullName
        $locationList[0].Description | Should -Be 'Location 1'
        $locationList[0].MachineNames.Count | Should -Be 1
        $locationList[0].MachineNames[0] | Should -Be $computer
        $locationList[0].Exist | Should -Be $true

        #covers 7 and 8 in the e2e-tests.md document
        #arrange:
        Set-Location -Path $e2eTestDir
        $wd = Get-Location
        $wd.Path | Should -Not -Be $testLoc1Fsi.FullName
        #act:
        $retVal = loc 0
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $wd = Get-Location
        $wd.Path | Should -Be $testLoc1Fsi.FullName

        #covers 9 and 10 in the e2e-tests.md document
        #arrange:
        Set-Location -Path $e2eTestDir
        $wd = Get-Location
        $wd.Path | Should -Not -Be $testLoc1Fsi.FullName
        #act:
        $retVal = loc 'Loc1'
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $wd = Get-Location
        $wd.Path | Should -Be $testLoc1Fsi.FullName

        #covers 11 and 12 in the e2e-tests.md document
        #act:
        $retVal = loc rename . 'Loc1_renamed'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 1
        $locationList[0].Name | Should -Be 'Loc1_renamed'
        $locationList[0].Path | Should -Be $testLoc1Fsi.FullName
        $locationList[0].Description | Should -Be 'Location 1'
        $locationList[0].MachineNames.Count | Should -Be 1
        $locationList[0].MachineNames[0] | Should -Be $computer
        $locationList[0].Exist | Should -Be $true

        #arrange:
        Set-Location -Path $e2eTestDir
        $wd = Get-Location
        $wd.Path | Should -Not -Be $testLoc1Fsi.FullName
        #act:
        $retVal = loc 'Loc1_renamed'
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $wd = Get-Location
        $wd.Path | Should -Be $testLoc1Fsi.FullName

        #act:
        $retVal = loc edit . 'Location 1 edited 1'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 1
        $locationList[0].Name | Should -Be 'Loc1_renamed'
        $locationList[0].Path | Should -Be $testLoc1Fsi.FullName
        $locationList[0].Description | Should -Be 'Location 1 edited 1'
        $locationList[0].MachineNames.Count | Should -Be 1
        $locationList[0].MachineNames[0] | Should -Be $computer
        $locationList[0].Exist | Should -Be $true

        #act:
        $retVal = loc edit 'Loc1_renamed' 'Location 1 edited 2'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 1
        $locationList[0].Name | Should -Be 'Loc1_renamed'
        $locationList[0].Path | Should -Be $testLoc1Fsi.FullName
        $locationList[0].Description | Should -Be 'Location 1 edited 2'
        $locationList[0].MachineNames.Count | Should -Be 1
        $locationList[0].MachineNames[0] | Should -Be $computer
        $locationList[0].Exist | Should -Be $true

        #act:
        $retVal = loc note . 'Loc 1 Note 1'
        $noteList = loc notes .
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $retVal.Location | Should -Be 'Loc1_renamed'
        $retVal.File | Should -Not -BeNullOrEmpty
        $retVal.Content | Should -Be 'Loc 1 Note 1'
        $noteList | Should -Not -BeNullOrEmpty
        $noteList.Count | Should -Be 1
        $noteList[0].Timestamp | Should -Not -BeNullOrEmpty
        $noteList[0].Content | Should -Be 'Loc 1 Note 1'

        #act:
        $retVal = loc note 'Loc1_renamed' 'Loc 1 Note 2'
        $noteList = loc notes 'Loc1_renamed'
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $noteList | Should -Not -BeNullOrEmpty
        $noteList.Count | Should -Be 2
        $noteList[1].Timestamp | Should -Not -BeNullOrEmpty
        $noteList[1].Content | Should -Be 'Loc 1 Note 2'

        #act:
        $retVal = loc rename . .
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -BeNullOrEmpty
        $retVal.Ok | Should -Be $true
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 1
        $locationList[0].Name | Should -Be 'Loc1'
        $locationList[0].Path | Should -Be $testLoc1Fsi.FullName
        $locationList[0].Description | Should -Be 'Location 1 edited 2'
        $locationList[0].MachineNames.Count | Should -Be 1
        $locationList[0].MachineNames[0] | Should -Be $computer
        $locationList[0].Exist | Should -Be $true

        #act:
        $retVal = loc where
        #assert:
        $retVal.Error | Should -BeNullOrEmpty
        $retVal.Ok | Should -Be $true
        $retVal.Location | Should -Be 'Loc1'
        $retVal.Description | Should -Be 'Location 1 edited 2'

        ##########

        #arrange:
        $Loc2Dir = Join-Path -Path $e2eTestDir -ChildPath "Loc2"
        $testLoc2Fsi = New-Item -ItemType Directory -Path $Loc2Dir
        Set-Location -Path $Loc2Dir
        #act:
        $retVal = loc add . 'Location 2'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 2
        $locationList[1].Name | Should -Be $testLoc2Fsi.Name
        $locationList[1].Path | Should -Be $testLoc2Fsi.FullName
        $locationList[1].Description | Should -Be 'Location 2'
        $locationList[1].MachineNames.Count | Should -Be 1
        $locationList[1].MachineNames[0] | Should -Be $computer
        $locationList[1].Exist | Should -Be $true

        #covers 7 and 8 in the e2e-tests.md document
        #arrange:
        Set-Location -Path $e2eTestDir
        $wd = Get-Location
        $wd.Path | Should -Not -Be $testLoc2Fsi.FullName
        #act:
        $retVal = loc 1
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $wd = Get-Location
        $wd.Path | Should -Be $testLoc2Fsi.FullName

        #covers 9 and 10 in the e2e-tests.md document
        #arrange:
        Set-Location -Path $e2eTestDir
        $wd = Get-Location
        $wd.Path | Should -Not -Be $testLoc2Fsi.FullName
        #act:
        $retVal = loc 'Loc2'
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $wd = Get-Location
        $wd.Path | Should -Be $testLoc2Fsi.FullName

        #act:
        $retVal = loc rename . 'Loc2_renamed'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 2
        $locationList[1].Name | Should -Be 'Loc2_renamed'
        $locationList[1].Path | Should -Be $testLoc2Fsi.FullName
        $locationList[1].Description | Should -Be 'Location 2'
        $locationList[1].MachineNames.Count | Should -Be 1
        $locationList[1].MachineNames[0] | Should -Be $computer
        $locationList[1].Exist | Should -Be $true

        #arrange:
        Set-Location -Path $e2eTestDir
        $wd = Get-Location
        $wd.Path | Should -Not -Be $testLoc2Fsi.FullName
        #act:
        $retVal = loc 'Loc2_renamed'
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $wd = Get-Location
        $wd.Path | Should -Be $testLoc2Fsi.FullName

        #act:
        $retVal = loc edit . 'Location 2 edited 1'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 2
        $locationList[1].Name | Should -Be 'Loc2_renamed'
        $locationList[1].Path | Should -Be $testLoc2Fsi.FullName
        $locationList[1].Description | Should -Be 'Location 2 edited 1'
        $locationList[1].MachineNames.Count | Should -Be 1
        $locationList[1].MachineNames[0] | Should -Be $computer
        $locationList[1].Exist | Should -Be $true

        #act:
        $retVal = loc edit 'Loc2_renamed' 'Location 2 edited 2'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 2
        $locationList[1].Name | Should -Be 'Loc2_renamed'
        $locationList[1].Path | Should -Be $testLoc2Fsi.FullName
        $locationList[1].Description | Should -Be 'Location 2 edited 2'
        $locationList[1].MachineNames.Count | Should -Be 1
        $locationList[1].MachineNames[0] | Should -Be $computer
        $locationList[1].Exist | Should -Be $true

        #act:
        $retVal = loc note . 'Loc 2 Note 1'
        $noteList = loc notes .
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $retVal.Location | Should -Be 'Loc2_renamed'
        $retVal.File | Should -Not -BeNullOrEmpty
        $retVal.Content | Should -Be 'Loc 2 Note 1'
        $noteList | Should -Not -BeNullOrEmpty
        $noteList.Count | Should -Be 1
        $noteList[0].Timestamp | Should -Not -BeNullOrEmpty
        $noteList[0].Content | Should -Be 'Loc 2 Note 1'

        #act:
        $retVal = loc note 'Loc2_renamed' 'Loc 2 Note 2'
        $noteList = loc notes 'Loc2_renamed'
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $noteList | Should -Not -BeNullOrEmpty
        $noteList.Count | Should -Be 2
        $noteList[1].Timestamp | Should -Not -BeNullOrEmpty
        $noteList[1].Content | Should -Be 'Loc 2 Note 2'

        #act:
        $retVal = loc rename . .
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -BeNullOrEmpty
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 2
        $locationList[1].Name | Should -Be 'Loc2'
        $locationList[1].Path | Should -Be $testLoc2Fsi.FullName
        $locationList[1].Description | Should -Be 'Location 2 edited 2'
        $locationList[1].MachineNames.Count | Should -Be 1
        $locationList[1].MachineNames[0] | Should -Be $computer
        $locationList[1].Exist | Should -Be $true

        #act:
        $retVal = loc where
        #assert:
        $retVal.Error | Should -BeNullOrEmpty
        $retVal.Ok | Should -Be $true
        $retVal.Location | Should -Be 'Loc2'
        $retVal.Description | Should -Be 'Location 2 edited 2'

        #act:
        Set-Location -Path $e2eTestDir
        Remove-Item -Path 'Loc2'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -BeNullOrEmpty
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 2
        $locationList[1].Name | Should -Be 'Loc2'
        $locationList[1].Path | Should -Be '!'
        $locationList[1].Description | Should -Be 'Location 2 edited 2'
        $locationList[1].MachineNames.Count | Should -Be 1
        $locationList[1].MachineNames[0] | Should -Be $computer
        $locationList[1].Exist | Should -Be $false

        #act:
        $retVal = loc repair
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -BeNullOrEmpty
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 1
        $locationList[0].Name | Should -Be 'Loc1'
        $locationList[0].Path | Should -Be $testLoc1Fsi.FullName
        $locationList[0].Description | Should -Be 'Location 1 edited 2'
        $locationList[0].MachineNames.Count | Should -Be 1
        $locationList[0].MachineNames[0] | Should -Be $computer
        $locationList[0].Exist | Should -Be $true

        #arrange:
        $env:LOC_MACHINE_NAME = 'TestMachine' # Simulate being on another machine
        #act:
        $statusData = loc status
        #assert:
        $statusData | Should -Not -BeNullOrEmpty
        $statusData.LocationCount | Should -Be 1
        $statusData.Version | Should -Not -BeNullOrEmpty
        $statusData.Build | Should -Not -BeNullOrEmpty
        $statusData.ComputerName | Should -Not -BeNullOrEmpty
        $statusData.ComputerName | Should -Be 'TestMachine'
        $statusData.LocationsDirectory | Should -Not -BeNullOrEmpty
        $statusData.LocationsDirectory | Should -Be $testLocationsDir

        #covers 5 and 6 in the e2e-tests.md document
        #arrange:
        $Loc1Machine2Dir = Join-Path -Path $e2eTestDir -ChildPath "Loc1_Macine2"
        $testLoc1Machine2Fsi = New-Item -ItemType Directory -Path $Loc1Machine2Dir
        Set-Location -Path $Loc1Machine2Dir
        #act:
        $retVal = loc update 'Loc1'
        $locationList = loc l o
        #assert:
        $retVal.Error | Should -Be $null
        $retVal.Ok | Should -Be $true
        $locationList | Should -Not -BeNullOrEmpty
        $locationList.Count | Should -Be 1
        $locationList[0].Name | Should -Be 'Loc1'
        $locationList[0].Path | Should -Be $testLoc1Machine2Fsi.FullName
        $locationList[0].Description | Should -Be 'Location 1 edited 2'
        $locationList[0].MachineNames.Count | Should -Be 2
        #$locationList[0].MachineNames[0] | Should -Be $computer
        $computer | Should -BeIn $locationList[0].MachineNames
        'TestMachine' | Should -BeIn $locationList[0].MachineNames
        $locationList[0].Exist | Should -Be $true
    }
}

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

        $e2eTestDir = Join-Path -Path $here -ChildPath "E2e_Test_Directory"
        if (Test-Path -Path $e2eTestDir) {
            Remove-Item -Path $e2eTestDir -Recurse -Force
        }

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

        #act:
        $statusData = loc status

        #assert:
        $statusData | Should -Not -BeNullOrEmpty
        $statusData.LocationCount | Should -Be 0
        $statusData.Debug | Should -Be 'False'
        $statusData.Version | Should -Not -BeNullOrEmpty
        $statusData.Build | Should -Not -BeNullOrEmpty
        $statusData.ComputerName | Should -Not -BeNullOrEmpty
        $statusData.ComputerName | Should -Be $computer
        $statusData.LocationsDirectory | Should -Not -BeNullOrEmpty
        $statusData.LocationsDirectory | Should -Be $testLocationsDir

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
        loc note . 'Loc 1 Note 1'

    }
}



Describe "PsLocations tests" {
    BeforeAll {
        $here = $PSScriptRoot
        $testLocDir = Join-Path -Path $here -ChildPath "TestLocations"
        # Import the module once before all tests
        Import-Module -Name "$here/../PsLocations.psm1"
        $env:LocHome = $testLocDir
    }

    It "loc status should create the testLocDir" {
        loc status

        $testLocDir | Should -Exist
    }
}
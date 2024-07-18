import:
	pwsh -Command "Import-Module -Name ./PsLocations" -Force

test:
	pwsh -Command "Invoke-Pester -Script PsLocations/tests/PsLocations.tests.ps1 -PassThru -CI"
	
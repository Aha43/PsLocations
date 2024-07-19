test:
	pwsh -Command "Invoke-Pester -Script PsLocations/tests/PsLocations.tests.ps1 -PassThru -CI"

clean:
	rm testResults.xml
	
test:
	pwsh -Command "Invoke-Pester -Script PsLocations/tests/PsLocations.tests.ps1 -PassThru -CI"

clean:
	rm testResults.xml

help:
	@echo "test - Run the tests"
	@echo "clean - Remove test results"
	@echo "help - Display this help message"
	
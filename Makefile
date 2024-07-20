test:
	pwsh -Command "Invoke-Pester -Script PsLocations/tests/PsLocations.tests.ps1 -PassThru -CI"

clean:
	pwsh -Command "./tools/CleanTest.ps1"

help:
	@echo "test - Run the tests"
	@echo "clean - Remove test results and any test data not removed by tests"
	@echo "help - Display this help message"
	
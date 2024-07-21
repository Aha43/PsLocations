.PHONY: all analyze

# Default target
all: analyze

# Target to install PSScriptAnalyzer if not already installed
install-analyzer:
	pwsh -Command "if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) { Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser }"

# Target to run PSScriptAnalyzer
analyze: install-analyzer
	@pwsh -NoProfile -ExecutionPolicy Bypass -File ./tools/analyze.ps1; \
	if [ $$? -ne 0 ]; then \
		echo "Analyze script failed with exit code $$?"; \
		exit 1; \
	fi

test: analyze
	pwsh -Command "Invoke-Pester -Script PsLocations/tests/PsLocations.tests.ps1 -PassThru -CI"

clean:
	pwsh -Command "./tools/CleanTest.ps1"

help:
	@echo "install-analyzer - Install PSScriptAnalyzer if not already installed"
	@echo "analyze - Run PSScriptAnalyzer"
	@echo "test - Run the tests"
	@echo "clean - Remove test results and any test data not removed by tests"
	@echo "help - Display this help message"
	
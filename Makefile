SHELL := /bin/bash

.PHONY: all analyze

# Default target
all: build

# Target to install PSScriptAnalyzer if not already installed
install-analyzer:
	pwsh -Command "if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) { Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser }"

# Target to run PSScriptAnalyzer
analyze: install-analyzer
	@pwsh -NoProfile -ExecutionPolicy Bypass -File ./tools/analyze.ps1 ; \
	if [ $$? -ne 0 ]; then \
		echo "Failed to pass script analyze"; \
		exit 1; \
	fi

test: analyze
	pwsh -Command "Invoke-Pester -Script PsLocations/tests/End2end.tests.ps1 -PassThru -CI"

build: test 
	@pwsh -Command "./tools/increment-build-number.ps1"

rawtest:
	pwsh -Command "Invoke-Pester -Script PsLocations/tests/End2end.tests.ps1 -PassThru -CI"

clean:
	pwsh -Command "./tools/clean-testdata.ps1"

help:
	@echo "install-analyzer - Install PSScriptAnalyzer if not already installed"
	@echo "analyze - Run PSScriptAnalyzer"
	@echo "test - Run the tests"
	@echo "build - Run the tests and increment the build number"
	@echo "rawtest - Run the tests without running the PSScriptAnalyzer"
	@echo "clean - Remove test results and any test data not removed by tests"
	@echo "help - Display this help message"
	
function AnalyzeScripts {
    param (
        [string]$Path = "."
    )

    # Ensure PSScriptAnalyzer is installed
    if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
        Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser
    }

    # Run PSScriptAnalyzer

    $results = Invoke-ScriptAnalyzer -Path $Path -Recurse -ExcludeRule PSAvoidUsingWriteHost

    # Output results and handle warnings/errors
    if ($results.Count -gt 0) {
        Write-Output "Script Analyzer found issues:"
        $results | Format-Table -AutoSize | Out-String
        $global:LASTEXITCODE = 1
        exit 1
    } else {
        Write-Output "No issues found by Script Analyzer."
        $global:LASTEXITCODE = 1
        return 0
    }
}

# Call the function with the default path
AnalyzeScripts

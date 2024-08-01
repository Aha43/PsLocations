function SetLocHome {
    # Check if LocHome environment variable is already set
    $currentLocHome = [System.Environment]::GetEnvironmentVariable("LocHome", "User")
    
    if ($currentLocHome) {
        Write-Output "LocHome is already set to: $currentLocHome"
        return
    }

    # Function to suggest a LocHome name
    function SuggestLocHome {
        $hostname = ""
        $username = $env:USER

        if ($IsWindows) {
            $hostname = (Get-WmiObject Win32_ComputerSystem).Name
        } elseif ($IsLinux -or $IsMacOS) {
            $hostname = (hostnamectl status -n 0 2> $null | Select-String -Pattern "Pretty hostname: (.+)").Matches.Groups[1].Value
            if (-not $hostname) {
                $hostname = hostname
            }
        }

        if ($hostname -and $username) {
            return "$hostname-$username"
        } else {
            return "LocHome-$username"
        }
    }

    # Function to sanitize the LocHome name
    function SanitizeName($name) {
        # Remove invalid characters for a directory name
        $invalidChars = [System.IO.Path]::GetInvalidFileNameChars() + [System.IO.Path]::GetInvalidPathChars()
        foreach ($char in $invalidChars) {
            $name = $name -replace [RegEx]::Escape($char), ''
        }
        return $name
    }

    # Suggest a name and prompt the user for input
    $suggestedName = SuggestLocHome
    Write-Output "Suggested LocHome: $suggestedName"
    $inputName = Read-Host "Enter LocHome name or press Enter to accept the suggested name"

    # Use the input name or the suggested name
    $LocHomeValue = if ([string]::IsNullOrWhiteSpace($inputName)) {
        $suggestedName
    } else {
        $inputName
    }

    # Sanitize the LocHome name to ensure it's a valid directory name
    $LocHomeValue = SanitizeName $LocHomeValue

    # Set the LocHome environment variable
    [System.Environment]::SetEnvironmentVariable("LocHome", $LocHomeValue, "User")
    Write-Output "LocHome is set to: $LocHomeValue"

    # Ask user if they want to persist the variable
    $persist = Read-Host "Do you want to persist this setting? (y/n)"
    if ($persist -eq 'y' -or $persist -eq 'Y') {
        # Determine the shell profile file
        if ($IsWindows) {
            $profileFile = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
        } elseif ($IsMacOS -or $IsLinux) {
            $profileFile = "$HOME/.bash_profile"
            if (-not (Test-Path $profileFile)) {
                $profileFile = "$HOME/.profile"
            }
        }

        # Add the environment variable to the profile file
        Add-Content -Path $profileFile -Value "`n`n# Set LocHome environment variable" -Force
        Add-Content -Path $profileFile -Value "export LocHome=`"$LocHomeValue`"" -Force

        Write-Output "LocHome variable persisted in $profileFile"
    } else {
        Write-Output "LocHome variable not persisted. It will only be available in this session."
    }
}

# Example usage
#Set-LocHome

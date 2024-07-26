function GetDebug {
    if ($env:LocDebug -eq 'True') {
        return $true
    } else {
        return $false
    }
}

function SwitchDebug {
    if ($env:LocDebug) {
        if ($env:LocDebug -eq 'True') {
            $env:LocDebug = 'False'
            Write-Host "Debug mode off" -ForegroundColor Green
        }
        else {
            $env:LocDebug = 'True'
            Write-Host "Debug mode on" -ForegroundColor Green
        }
    }
    else {
        $env:LocDebug = 'True'
        Write-Host "Debug mode on" -ForegroundColor Green
    }
}

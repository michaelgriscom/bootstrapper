#Requires -RunAsAdministrator

# Show Task Manager details
Function ShowTaskManagerDetails {
    Write-Host "Showing task manager details..."
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Force | Out-Null
    }

    $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
    If (!($preferences)) {
        $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
        While (!($preferences)) {
            Start-Sleep -m 250
            $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
        }
        Stop-Process $taskmgr
    }

    $preferences.Preferences[28] = 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
}

Function Enable-WSL {
    Write-Host "Installing Linux Subsystem..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

$REG_KEYS_PATH = "$PSScriptRoot\reg-keys.csv"
function Load-Keys() {
    if (Test-Path $REG_KEYS_PATH) {
        $script:keys = Get-Content $REG_KEYS_PATH | ConvertFrom-Csv |
            select path, name, type, value, description
    }
    else {
        Write-Error "Reg key csv doesn't exist, this is a fatal error!"
        Exit 1
    }
}

function Set-Reg-Key($key) {
    echo $key.description
    Set-ItemProperty -Path $key.path -Name $key.name -Type $key.type -Value $key.value
}

Load-Keys
ForEach ($key in $script:keys) {
    Set-Reg-Key $key
}

ShowTaskManagerDetails
Enable-WSL

# exclude git folder from defender scans
Add-MpPreference -ExclusionPath "c:\git"
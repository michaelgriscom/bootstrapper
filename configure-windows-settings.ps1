#Requires -RunAsAdministrator

# Show Task Manager details
function ShowTaskManagerDetails {
    Write-Host "Showing task manager details..."
    if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Force | Out-Null
    }

    $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
    if (!($preferences)) {
        $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -Passthru
        while (!($preferences)) {
            Start-Sleep -m 250
            $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
        }
        Stop-Process $taskmgr
    }

    $preferences.Preferences[28] = 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Value $preferences.Preferences
}

function Enable-WSL {
    Write-Host "Installing Linux Subsystem..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Value 1
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

$REG_KEYS_PATH = "$PSScriptRoot\reg-keys.csv"
function Load-Keys () {
    if (Test-Path $REG_KEYS_PATH) {
        $script:keys = Get-Content $REG_KEYS_PATH | ConvertFrom-Csv |
        Select-Object path,name,Get-Content,value,description
    }
    else {
        Write-Error "Reg key csv doesn't exist, this is a fatal error!"
        exit 1
    }
}

function Set-Reg-Key ($key) {
    Write-Host $key.description
    if (!(Test-Path $key.path)) {
        New-Item -Path $key.path -Force | Out-Null
    }

    Set-ItemProperty -Path $key.path -Name $key.Name -Value $key.value
}

Load-Keys
foreach ($key in $script:keys) {
    Set-Reg-Key $key
}

ShowTaskManagerDetails
Enable-WSL

# exclude git folder from defender scans
Add-MpPreference -ExclusionPath "c:\git"

# Remove Edge shortcut from desktop
Remove-Item "C:\Users\*\Desktop\Microsoft Edge.lnk"

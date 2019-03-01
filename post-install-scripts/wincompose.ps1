Write-Output "Copying WinCompose settings"
Copy-Item -Path "$PSScriptRoot\..\resources\wincompose\.XCompose" -Destination "$env:USERPROFILE"

echo "Copying WinCompose settings"
Copy-Item -Path "$PSScriptRoot\resources\.XCompose" -Destination "$env:USERPROFILE"
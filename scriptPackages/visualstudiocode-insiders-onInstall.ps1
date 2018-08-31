echo "Copying VSCode settings"
Copy-Item -Path "$PSScriptRoot\..\resources\vscode\keybindings.json" -Destination "$env:APPDATA\Code - Insiders\User"
Copy-Item -Path "$PSScriptRoot\..\resources\vscode\settings.json" -Destination "$env:APPDATA\Code - Insiders\User"
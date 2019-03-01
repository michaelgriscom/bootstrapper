echo "Copying VSCode settings"
Copy-Item -Path "$PSScriptRoot\..\resources\vscode\keybindings.json" -Destination "$env:APPDATA\Code\User"
Copy-Item -Path "$PSScriptRoot\..\resources\vscode\settings.json" -Destination "$env:APPDATA\Code\User"

# VSCode is self-updating
choco pin add --name vscode
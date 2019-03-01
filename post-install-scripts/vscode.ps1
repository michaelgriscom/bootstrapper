Write-Host "Copying VSCode settings"
$vscodeSettingsPath = "$env:APPDATA\Code\User"

if (!(test-path $vscodeSettingsPath)) {
    New-Item $vscodeSettingsPath -ItemType Directory
}

Copy-Item -Path "$PSScriptRoot\..\resources\vscode\keybindings.json" -Destination $vscodeSettingsPath
Copy-Item -Path "$PSScriptRoot\..\resources\vscode\settings.json" -Destination $vscodeSettingsPath

# VSCode is self-updating
choco pin add --name vscode
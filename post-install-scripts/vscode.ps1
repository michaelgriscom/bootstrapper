Write-Host "Copying VSCode settings"
$vscodeSettingsPath = "$env:APPDATA\Code\User"

if (!(Test-Path $vscodeSettingsPath)) {
    New-Item $vscodeSettingsPath -ItemType Directory
}

Copy-Item -Path "$PSScriptRoot\..\resources\vscode\keybindings.json" -Destination $vscodeSettingsPath
Copy-Item -Path "$PSScriptRoot\..\resources\vscode\settings.json" -Destination $vscodeSettingsPath

refreshenv

# Install extensions
code --install-extension ban.spellright
code --install-extension CoenraadS.bracket-pair-colorizer
code --install-extension eamodio.gitlens
code --install-extension eg2.tslint
code --install-extension eg2.vscode-npm-script
code --install-extension felipecaputo.git-project-manager
code --install-extension jakob101.RelativePath
code --install-extension michaelgriscom.leadermode
code --install-extension ms-vscode.PowerShell
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension Tyriar.sort-lines

# VSCode is self-updating
choco pin add --name vscode

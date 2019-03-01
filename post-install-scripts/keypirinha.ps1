Write-Host "Copying keyirinha settings"

$keyPirinhaSettingsPath = "$env:APPDATA\Keypirinha\User"

if (!(test-path $keyPirinhaSettingsPath)) {
    New-Item $keyPirinhaSettingsPath -ItemType Directory
}

Copy-Item -Path "$PSScriptRoot\..\resources\keypirinha\Keypirinha.ini" -Destination $keyPirinhaSettingsPath
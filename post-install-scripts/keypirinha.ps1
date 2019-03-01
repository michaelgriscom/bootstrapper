Write-Host "Copying keyirinha settings"
Copy-Item -Path "$PSScriptRoot\..\resources\keypirinha\Keypirinha.ini" -Destination "$env:APPDATA\Keypirinha\User"
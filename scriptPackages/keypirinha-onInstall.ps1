echo "Copying VSCode settings"
Copy-Item -Path "$PSScriptRoot\..\resources\keypirinha\Keypirinha.ini" -Destination "$env:APPDATA\\User"
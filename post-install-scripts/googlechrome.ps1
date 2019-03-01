# Chrome is self-updating
choco pin add --name GoogleChrome

# Remove desktop icon; not currently supported through chocolatey
Remove-Item "C:\Users\*\Desktop\Google Chrome.lnk"

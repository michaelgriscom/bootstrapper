my spacemacs config & setup file
=========================================

spacemacs config plus a powershell script to make sure everything's in place


setup
======
paste this into an admin powershell
    Set-ExecutionPolicy Unrestricted
    wget https://raw.githubusercontent.com/mjlim/.spacemacs.d/master/scripts/eupdate.ps1 -OutFile $env:temp/emacsbootstrap.ps1
    Invoke-Expression $env:temp/emacsbootstrap.ps1

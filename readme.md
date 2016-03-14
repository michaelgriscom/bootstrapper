my spacemacs config & setup file
=========================================

spacemacs config plus a powershell script to make sure everything's in place


setup (windows)
======
paste this into an admin powershell

    set-executionpolicy unrestricted
    wget https://raw.githubusercontent.com/mjlim/.spacemacs.d/master/scripts/eupdate.ps1 -outfile $env:temp/emacsbootstrap.ps1
    invoke-expression $env:temp/emacsbootstrap.ps1


setup (linux)
======
todo lol

Machine setup script
=========================================

Powershell script to set up a machine, along with a spacemacs configuration

Setup (windows)
======
paste this into an admin powershell

    set-executionpolicy unrestricted
    wget https://raw.githubusercontent.com/michaelgriscom/bootstrapper/master/scripts/eupdate.ps1 -outfile $env:temp/bootstrapper.ps1
    invoke-expression $env:temp/bootstrapper.ps1

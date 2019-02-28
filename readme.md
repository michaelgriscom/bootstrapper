Machine setup script
=========================================

Powershell script to set up a machine

Setup (windows)
======
paste this into an admin powershell

    set-executionpolicy unrestricted
	wget https://raw.githubusercontent.com/michaelgriscom/bootstrapper/master/bootstrap.ps1 -outfile $env:temp/bootstrap.ps1
	invoke-expression $env:temp/bootstrap.ps1

Machine setup script
=========================================

Powershell script to set up a machine, along with a spacemacs configuration

Setup (windows)
======
paste this into an admin powershell

```
set-executionpolicy unrestricted
iwr https://raw.githubusercontent.com/michaelgriscom/bootstrapper/master/bootstrap.ps1 -UseBasicParsing | iex
```
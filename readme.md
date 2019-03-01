Machine setup script
=========================================

Powershell script to set up a machine

- Installs and configures programs through chocolatey
- Uninstalls bloatware
- Configures system settings

Instructions
======
Execute this in powershell:

```
set-executionpolicy unrestricted Process -Force
iwr https://raw.githubusercontent.com/michaelgriscom/bootstrapper/master/bootstrap.ps1 -UseBasicParsing | iex
```

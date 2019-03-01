function Verify-Elevated {
    # Get the ID and security principal of the current user account
    $myIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myPrincipal = New-Object System.Security.Principal.WindowsPrincipal ($myIdentity)
    # Check to see if we are currently running "as Administrator"
    return $myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);

    exit
}

if (!(Get-Command "choco.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey"
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

    # Make `refreshenv` available right away, by defining the $env:ChocolateyInstall variable
    # and importing the Chocolatey profile module.
    $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).path)\..\.."
    Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

    refreshenv
}

if (!(Get-Command "git.exe" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing git"
    choco install -y git -params '"/GitAndUnixToolsOnPath"'
    refreshenv

    # git perf tweaks
    git config --global core.preloadindex true
    git config --global core.fscache true
    git config --global gc.auto 256
}

$repoPath = "c:\git"
$bootstrapperPath = "$repoPath/bootstrapper"

if (!(Test-Path $bootstrapperPath)) {
    New-Item $bootstrapperPath -ItemType Directory

    pushd $bootstrapperPath
    git clone https://github.com/michaelgriscom/bootstrapper.git .
    popd
}

Write-Host "Installing applications" -ForegroundColor "Yellow"
Invoke-Expression $bootstrapperPath/install-apps.ps1

Write-Host "Removing bloatware" -ForegroundColor "Yellow"
Invoke-Expression $bootstrapperPath/remove-bloatware.ps1

Write-Host "Configuring Windows" -ForegroundColor "Yellow"
Invoke-Expression $bootstrapperPath/configure-windows-settings.ps1

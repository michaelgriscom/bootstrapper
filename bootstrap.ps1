#Requires -RunAsAdministrator

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

if (!(test-path $repoPath)) {
    New-Item $repoPath -ItemType Directory
}

if (!(test-path $repoPath/bootstrapper)) {
    pushd $repoPath
    git clone https://github.com/michaelgriscom/bootstrapper.git .
    popd
}

# exclude folder from defender scans
Add-MpPreference -ExclusionPath $repoPath

Invoke-Expression $repoPath/bootstrapper/setup-packages.ps1
Invoke-Expression $repoPath/bootstrapper/configure-explorer.ps1
Invoke-Expression $repoPath/bootstrapper/remove-default-apps.ps1
Invoke-Expression $repoPath/bootstrapper/enable-wsl.ps1
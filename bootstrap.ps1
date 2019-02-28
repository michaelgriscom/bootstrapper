#Requires -RunAsAdministrator

if (!(Get-Command "choco.exe" -ErrorAction SilentlyContinue)) {
    echo "Installing Chocolatey"
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
    refreshenv
}

$repoPath = "c:\git"

if (!(test-path $repoPath)) {
    New-Item $repoPath -ItemType Directory

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
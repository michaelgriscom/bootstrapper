#Requires -RunAsAdministrator

#param (
#[switch] $clean
#)

$PACKAGES_PATH = "$PSScriptRoot\packages.csv"

function Load-Packages()
{
    if (Test-Path $PACKAGES_PATH)
    {
        $script:packages = Get-Content $PACKAGES_PATH | ConvertFrom-Csv |
          select packagename, params
    }
    else
    {
        echo "Package csv doesn't exist, this is a fatal error!"
        Exit 1
    }
}

function Install-Choco-Package($package)
{
    choco upgrade -y $package.packagename -params $package.params --allowEmptyChecksums --limit-output
    Run-Script-Package $package "-onInstall"
}

function Run-Script-Package($package, $suffix = "")
{
    $scriptPath = "$PSScriptRoot\scriptPackages\$($package.packagename)$suffix.ps1"
    if (Test-Path $scriptPath)
    {
        echo "Running: $scriptPath"
        . $scriptPath
    }
}

Load-Packages

# update setup files
pushd $PSScriptRoot
git pull
$gitExitCode = $LASTEXITCODE
popd

if ($gitExitCode -ne 0)
{
    Save-State
    echo "Git encountered an error, please resolve before updating again."
    Exit 1
}

ForEach ($package in $script:packages)
{
    echo "Installing/updating package: $($package.packagename)"
    if ($package.packagename -match '\.ps1')
    {
        echo "Executing: $($package.packagename)"
        # replace packagename
        $package.packagename = ($package.packagename -replace '\.ps1', '')
        Run-Script-Package $package
    }
    else
    {
        Install-Choco-Package $package
    }
}
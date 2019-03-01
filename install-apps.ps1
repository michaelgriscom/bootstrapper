#Requires -RunAsAdministrator

$PACKAGES_PATH = "$PSScriptRoot\packages.csv"

function Load-Packages () {
    if (Test-Path $PACKAGES_PATH) {
        $script:packages = Get-Content $PACKAGES_PATH | ConvertFrom-Csv |
        Select-Object packagename,params,flags
    }
    else {
        Write-Error "Package csv doesn't exist, this is a fatal error!"
        exit 1
    }
}

function Install-Choco-Package ($package) {
    choco install -y $package.packagename -params $package.params --allowEmptyChecksums --limit-output $package.flags
    Run-Script-Package $package
}

function Run-Script-Package ($package) {
    $scriptPath = "$PSScriptRoot\post-install-scripts\$($package.packagename).ps1"
    if (Test-Path $scriptPath) {
        Write-Host "Running: $scriptPath"
        .$scriptPath
    }
}

Load-Packages

# update setup files
pushd $PSScriptRoot
git pull
$gitExitCode = $LASTEXITCODE
popd

if ($gitExitCode -ne 0) {
    Save-State
    Write-Error "Git encountered an error, please resolve before updating again."
    exit 1
}

foreach ($package in $script:packages) {
    Install-Choco-Package $package
}

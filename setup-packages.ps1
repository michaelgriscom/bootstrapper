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
          select packagename, category, params,
          @{n='excluded'; e={[bool]($script:state.ExcludedPackages -contains $_.packagename)}}
    }
    else
    {
        echo "Package csv doesn't exist, this is a fatal error!"
        Exit 1
    }
}

function Update-Choco-Package($package)
{
    echo "Outdated package: $($package.packagename) updating..."

    choco upgrade -y $package.packagename --allowEmptyChecksums --limit-output
}

function Do-Package($package)
{
    if ($package.packagename -match '\.ps1')
    {
        scho "$($package.packagename) ends with .ps1, running the script"
        # replace packagename
        $package.packagename = ($package.packagename -replace '\.ps1', '')
        Run-ScriptPackage $package
        return
    }

    # if the package is installed, then it should already be up to date; otherwise we must install it
    $packageIsInstalled = choco info $($package.packagename) -ne $null
    if ($packageIsInstalled)
    {
        return
    }

    echo "Package not found: $($package.packagename) installing..."
    choco install -y $package.packagename --allowEmptyChecksums --limit-output
    Run-Script-Package $package "-onInstall"
}

function Run-Script-Package($package, $suffix = "")
{
    $scriptPath = "$PSScriptRoot\scriptPackages\$($package.packagename)$suffix.ps1"
    echo "Looking for a script package in $scriptPath"
    if (Test-Path $scriptPath)
    {
        echo "Found a script, running it."
        . $scriptPath
    }
}

Load-State
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

$outdatedPackages = choco outdated
ForEach($outdatedPackage in $outdatedPackages)
{
    Update-Choco-Package $outdatedPackage
}

ForEach ($package in $script:packages)
{
    Do-Package $package
}

Run-Script-Package $package "-onUpdate"

Save-State
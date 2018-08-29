if (!(Get-Command "choco.exe" -ErrorAction SilentlyContinue))
{
    echo "Installing Chocolatey"
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
    refreshenv
}

if (!(Get-Command "git.exe" -ErrorAction SilentlyContinue))
{
    choco upgrade git -y -params '"/GitAndUnixToolsOnPath"'
    refreshenv
}

if (!(Get-Command "git.exe" -ErrorAction SilentlyContinue))
{
    if (Test-Path "C:\Program Files\Git\cmd\git.exe")
    {
        echo "Adding git to path"
        [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";C:\Program Files\Git\cmd\", "Machine")
        refreshenv
        $Env:Path = $Env:Path + ";C:\Program Files\Git\cmd\"
    }
    else
    {
        echo "WARNING: Couldn't find Git in the path and also in C:\Program Files\Git\cmd"
    }
}

$bootstrapperPath = "c:\git"

if (!(test-path $bootstrapperPath))
{
    New-Item $bootstrapperPath -ItemType Directory

    pushd $bootstrapperPath
    git clone https://github.com/michaelgriscom/bootstrapper.git
    popd
}

Invoke-Expression $bootstrapperPath/bootstrapper/setup-packages.ps1
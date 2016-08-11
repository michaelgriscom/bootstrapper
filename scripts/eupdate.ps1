#requires -version 4.0
#requires -RunAsAdministrator

param (
    [switch] $dev,
    [switch] $full
)

function Refresh-Env()
{
    refreshenv
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
}

function Configure-Git()
{
    if (!(Get-Command "git.exe" -ErrorAction SilentlyContinue))
    {
       Write-Warning "Couldn't find git."
       return
    }

    echo "This machine has git. Configuring for performance on Windows."
    git config --global core.preloadindex true
    git config --global core.fscache true
    git config --global gc.auto 256

    if (Test-path $env:USERPROFILE/.spacemacs.d/)
    {
        echo ".spacemacs.d exists. updating it..."
        pushd $env:USERPROFILE/.spacemacs.d
        git pull origin master
        popd
    }
    else
    {
        echo ".spacemacs.d doesn't exist. cloning from my github"
        pushd $env:USERPROFILE
        git clone git@github.com:michaelgriscom/.spacemacs.d.git
        if (!(Test-path $env:USERPROFILE/.spacemacs.d/))
        {
            echo "cloning failed. falling back to https clone"
            git clone https://github.com/michaelgriscom/.spacemacs.d.git
        }
        popd
    }

    if (Test-path $env:USERPROFILE/.emacs.d/)
    {
        echo ".emacs.d exists (spacemacs is installed). checking for updates"
        pushd $env:USERPROFILE/.emacs.d
        git pull
        popd
    }
    else
    {
        echo ".emacs.d doesn't exist, cloning spacemacs."
        pushd $env:USERPROFILE
        git clone https://github.com/syl20bnr/spacemacs .emacs.d
        popd

        # fix emacs.d/server identity for the hell of it (could be broken on some machines)
        $serverpath = "$env:USERPROFILE/.emacs.d/server"
        if (Test-Path $serverpath)
        {
            $user = [System.Security.Principal.WindowsIdentity]::GetCurrent()
            $acl = Get-ACL $serverpath
            $acl.SetOwner($user.User)
            Set-Acl -Path $serverpath -AclObject $acl
        }
    }
}

function Configure-Env()
{
    if (!$env:HOME) # emacs looks here to pull in the spacemacs config.
    {
        echo "Setting HOME environment variable to $env:USERPROFILE"
        [Environment]::SetEnvironmentVariable("HOME", $env:USERPROFILE, "Machine")
    }
    else
    {
        echo "HOME environment variable already exists and is $env:HOME"
    }

    if (Get-Command "e.bat" -ErrorAction SilentlyContinue)
    {
        echo "This machine has e.bat in the path"
    }
    else
    {
        echo "Adding scripts to path"
        [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";" + $env:USERPROFILE + "\.spacemacs.d\scripts\", "Machine")
        Refresh-Env
    }

    if (Test-Path $env:USERPROFILE\bin\)
    {
        echo "This machine has a local bin directory in the path"
    }
    else
    {
        echo "This machine does not have a local bin directory in the path. Creating & adding to path."
        mkdir $env:USERPROFILE\bin\
        [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";" + $env:USERPROFILE + "\bin\", "Machine")
        Refresh-Env
    }
}

function Update-Chocolatey-Packages()
{
    if (!(Get-Command "choco.exe" -ErrorAction SilentlyContinue))
    {
        echo "Installing Chocolatey"
        iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
        refreshenv
    }

    echo "Installing/Updating Chocolatey packages"

    echo "Adding core apps"
    choco upgrade pt -y
    choco upgrade emacs64 -y
    choco upgrade git -y -params '"/GitAndUnixToolsOnPath"'
    choco upgrade -y googlechrome
    choco upgrade -y paint.net
    choco upgrade -y spotify
    choco upgrade -y notepadplusplus
    choco upgrade -y everything

    if($dev -or $full)
    {
        echo "Adding dev tools"
        choco upgrade -y sysinternals
        choco upgrade -y fiddler4
        choco upgrade -y sourcetree
        choco upgrade -y visualstudio2015enterprise
        choco upgrade -y resharper
        choco upgrade -y winmerge
    }

    if($full)
    {
        echo "Adding misc tools"
        choco upgrade winrar -y   
        # f.lux
        # nodejs
        # lessmsi
    }
}

function Configure-Reg()
{
    echo "Adding emacs shell integration"
    $regLoc = $env:USERPROFILE + "\.spacemacs.d\scripts\openwemacs.reg"
    regedit /s $regLoc # doing reg operations through PS is way slower than just running this
}

Set-ExecutionPolicy unrestricted
Update-Chocolatey-Packages
echo "Configuring some things"
Refresh-Env
Configure-Git
Configure-Env
Configure-Reg
Refresh-Env
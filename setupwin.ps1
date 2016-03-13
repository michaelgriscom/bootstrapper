##Requires -RunAsAdministrator

if (!$env:HOME) # emacs looks here to pull in the spacemacs config.
{
    echo "Setting HOME environment variable to $env:USERPROFILE"
    [Environment]::SetEnvironmentVariable("HOME", $env:USERPROFILE, "Machine")
}
else
{
    echo "HOME environment variable already exists and is $env:HOME"
}

if (Get-Command "git.exe" -ErrorAction SilentlyContinue)
{
    echo "This machine has git."
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
        git clone git@github.com:mjlim/.spacemacs.d.git
        popd
    }
}
else
{
    echo "This machine doesn't have git."
    echo "todo: get git and make sure it's in path. right now: exiting."
    Exit
}

# check that emacs is on this pc
if (Test-Path c:\emacs)
{
    #ok
    echo "This machine has emacs installed."
}
else
{
    echo "This machine doesn't have emacs installed; getting it & installing to c:\emacs"
    wget http://d.mjlim.net/~mikel/emacs.zip -outfile $env:temp\emacs.zip
    Expand-Archive $env:temp\emacs.zip -dest c:\
}

# check regkey to turn off scaling
$layers = Get-Item "hklm:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers\"
if ($layers.GetValueNames().Contains("c:\emacs\bin\emacs.exe"))
{
    echo "This machine has the highdpi aware registry flags set on the emacs exes."
}
else
{
    echo "This machine doesn't have the highdpi aware registry flags set on the emacs exes, setting them..."
    $layers | New-ItemProperty -name "c:\emacs\bin\emacs.exe" -value "~ HIGHDPIAWARE"
    $layers | New-ItemProperty -name "c:\emacs\bin\runemacs.exe" -value "~ HIGHDPIAWARE"
    echo "if that failed, try again as admin."
}




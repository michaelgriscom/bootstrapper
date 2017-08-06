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
    git clone https://github.com/michaelgriscom/.spacemacs.d.git
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
}

# Add "open with emacs" to context menu
regedit /s $PSScriptRoot/emacs64/openwemacs.reg
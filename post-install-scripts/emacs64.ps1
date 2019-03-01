$serverpath = "$env:USERPROFILE/.emacs.d/server"
if (Test-Path $serverpath) {
    $user = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $acl = Get-Acl $serverpath
    $acl.SetOwner($user.User)
    Set-Acl -Path $serverpath -AclObject $acl
}

if (!$env:HOME) { # emacs looks here to pull in the spacemacs config.
    Write-Output "Setting HOME environment variable to $env:USERPROFILE"
    [Environment]::SetEnvironmentVariable("HOME",$env:USERPROFILE,"Machine")
}
else {
    Write-Output "HOME environment variable already exists and is $env:HOME"
}

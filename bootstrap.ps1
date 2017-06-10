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

function Clone-Repos()
{
    if (Test-path $env:USERPROFILE/.spacemacs.d/)
    {
        echo ".spacemacs.d exists. updating it..."
        pushd $env:USERPROFILE/.spacemacs.d
        git pull origin master
        popd
    }
    else
    {
        echo ".spacemacs.d doesn't exist. cloning from github"
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

    Clone-Repos
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
        [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";" + $env:USERPROFILE + "\bootstrapper\bin\", "Machine")
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
    choco upgrade -y spotify
    choco upgrade -y notepadplusplus
    choco upgrade -y everything
    choco upgrade -y microsoft-teams

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
        choco upgrade -y paint.net
    }
}

function Configure-PS()
{
    if (!(Get-Command "PSReadline" -ErrorAction SilentlyContinue)){
        echo "PSReadline not found. Trying to install it."
        Install-Package PSReadline
    }
}

function Fix-Emacs()
{
    # fix emacs.d/server identity
    $serverpath = "$env:USERPROFILE/.emacs.d/server"
    if (Test-Path $serverpath)
    {
        $user = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $acl = Get-ACL $serverpath
        $acl.SetOwner($user.User)
        Set-Acl -Path $serverpath -AclObject $acl
    }
}

# Enable Remote Desktop w/o Network Level Authentication
Function EnableRemoteDesktop {
	Write-Host "Enabling Remote Desktop w/o Network Level Authentication..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 0
}

# Show Task Manager details
Function ShowTaskManagerDetails {
	Write-Host "Showing task manager details..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Force | Out-Null
	}
	$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
	If (!($preferences)) {
		$taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
		While (!($preferences)) {
			Start-Sleep -m 250
			$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
		}
		Stop-Process $taskmgr
	}
	$preferences.Preferences[28] = 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
}

# Show file operations details
Function ShowFileOperationsDetails {
	Write-Host "Showing file operations details..."
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1
}

# Show known file extensions
Function ShowKnownExtensions {
	Write-Host "Showing known file extensions..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
}

# Show hidden files
Function ShowHiddenFiles {
	Write-Host "Showing hidden files..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
}

# Change default Explorer view to This PC
Function ExplorerThisPC {
	Write-Host "Changing default Explorer view to This PC..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
}

# Install Linux Subsystem - Applicable to RS1 or newer
Function InstallLinuxSubsystem {
	Write-Host "Installing Linux Subsystem..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
	Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

Function DisableShaking {
	Write-Host "Disabling shaking..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Type DWord -Value 1
}

Function DisableQuickEdit {
	Write-Host "Disabling quick edit..."
	Set-ItemProperty -Path "HKCU:\Console" -Name "QuickEdit" -Type DWord -Value 0
}

function Configure-Reg()
{
	EnableRemoteDesktop
	ShowTaskManagerDetails
	ShowFileOperationsDetails
	ShowKnownExtensions
	ShowHiddenFiles
	DisableShaking
	DisableQuickEdit
	ExplorerThisPC
	# InstallLinuxSubsystem
}

Set-ExecutionPolicy unrestricted
Update-Chocolatey-Packages
echo "Configuring some things"
Refresh-Env
Configure-PS
Configure-Git
Configure-Env
Configure-Reg
Fix-Emacs
Refresh-Env

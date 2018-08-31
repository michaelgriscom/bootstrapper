function AddPsProfile() {
    if (!(Get-Content $profile | Select-String "psprofile.ps1" -Quiet)) {
        echo "Powershell profile doesn't call my profile script, adding to $profile and running it"
        Add-Content $profile ". $PSScriptRoot\..\psprofile.ps1"
        . $PSScriptRoot\..\psprofile.ps1
    }
    else {
        echo "Powershell profile calls my profile script."
    }
}

AddPsProfile
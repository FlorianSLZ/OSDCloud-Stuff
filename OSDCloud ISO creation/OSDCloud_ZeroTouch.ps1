<#
.SYNOPSIS

.DESCRIPTION

.NOTES
    Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
    Version: 1.0

    Changelog:
    - 2024-08-15: 1.0 Initial version
    
#>


# Set Workspace Folder
$ProjectName = "OSDCloud-by-scloud"
$WorkspacePath = "C:\OSDCloud\$ProjectName"
New-Item -ItemType Directory $WorkspacePath -Force | Out-Null
Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath

# Blank Template
New-OSDCloudTemplate 


# Zero Touch via GitHub script
Edit-OSDCloudWinPE  -WorkspacePath $WorkspacePath `
                    -WebPSScript "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OSDPad/OSDCloud-W11-23H2-DE-FR-IT-EN_wUpdates.ps1" `
                    -Wallpaper "C:\GitHub\OSDCloud-Stuff\OSDCloud ISO creation\scloud-wallpaper.jpg" `
                    -CloudDriver *


# Save the changes to ISO
New-OSDCloudISO -WorkspacePath $WorkspacePath
$FinalISO = "OSDCloud-$ProjectName.iso"
if(Test-Path "$WorkspacePath\$FinalISO"){
    Remove-Item -Path "$WorkspacePath\$FinalISO" -Force
}
Rename-Item -Path "$WorkspacePath\OSDCloud_NoPrompt.iso" -NewName "$WorkspacePath\$FinalISO" -Force


<#
.SYNOPSIS

.DESCRIPTION

.NOTES
    Author: Florian Salzmann | UMB
    Version: 1.0

    Changelog:
    - 2026-03-19: 1.0 Initial version
    
#>


# Set Workspace Folder
$ProjectName = "OSDCloud-Windows-MultiArch"
$WorkspacePath = "C:\OSDCloud\$ProjectName"
New-Item -ItemType Directory $WorkspacePath -Force | Out-Null
Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath

# Blank Template
New-OSDCloudTemplate 


# Multi Architecture via GitHub script
Edit-OSDCloudWinPE  -WorkspacePath $WorkspacePath `
                    -WebPSScript "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/refs/heads/main/OSDPad/OSDCloud-Windows-MultiArch.ps1" # `
  #                  -CloudDriver *



# Save the changes to ISO
New-OSDCloudISO -WorkspacePath $WorkspacePath
$FinalISO = "$ProjectName.iso"
if(Test-Path "$WorkspacePath\$FinalISO"){
    Remove-Item -Path "$WorkspacePath\$FinalISO" -Force
}
Rename-Item -Path "$WorkspacePath\OSDCloud_NoPrompt.iso" -NewName "$WorkspacePath\$FinalISO" -Force
start-sleep 5
Write-Host -ForegroundColor Green "ISO created: $WorkspacePath\$FinalISO"

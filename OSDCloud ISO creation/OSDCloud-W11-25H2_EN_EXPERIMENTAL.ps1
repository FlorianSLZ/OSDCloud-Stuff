<#
.SYNOPSIS

.DESCRIPTION

.NOTES
    Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
    Version: 1.0

    Changelog:
    - 2026-06-29: 1.0 Initial version
    
#>


# Set Workspace Folder
$ProjectName = "OSDCloud-v2_EXPERIMENTAL"
$WorkspacePath = "C:\OSDCloud\$ProjectName"
New-Item -ItemType Directory $WorkspacePath -Force | Out-Null
Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath

# Blank Template
New-OSDCloudTemplate 


# OSDCloud v2 Start
Edit-OSDCloudWinPE  -WorkspacePath $WorkspacePath `
                    -StartPSCommand 'Install-Module -Name OSDCloud -Force -SkipPublisherCheck; Deploy-OSDCloud; Restart-Computer' `
                    -CloudDriver *


# Save the changes to ISO
New-OSDCloudISO -WorkspacePath $WorkspacePath
$FinalISO = "OSDCloud-$ProjectName.iso"
if(Test-Path "$WorkspacePath\$FinalISO"){
    Remove-Item -Path "$WorkspacePath\$FinalISO" -Force
}
Rename-Item -Path "$WorkspacePath\OSDCloud_NoPrompt.iso" -NewName "$WorkspacePath\$FinalISO" -Force

Write-Host -ForegroundColor Green "ISO created: $WorkspacePath\$FinalISO"

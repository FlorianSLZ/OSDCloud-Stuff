<#
.SYNOPSIS

.DESCRIPTION

.NOTES
    Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
    Version: 1.0

    Changelog:
    - 2024-04-07: 1.0 Initial version
    
#>


# Set Workspace Folder
$ProjectName = "W11-24H2_DE-Basic"
$WorkspacePath = "C:\OSDCloud\$ProjectName"
New-Item -ItemType Directory $WorkspacePath -Force | Out-Null
Set-OSDCloudWorkspace -WorkspacePath $WorkspacePath

# Blank Template
New-OSDCloudTemplate 


# Zero Touch
Edit-OSDCloudWinPE  -WorkspacePath $WorkspacePath `
                    -StartOSDCloudGUI `
                    -Brand $ProjectName `
                    -CloudDriver *

Edit-OSDCloudWinPE -StartOSDCloud '-ZTI -Restart -OSName ''Windows 11 24H2 x64'' -OSEdition Enterprise -OSLanguage de-de -OSLicense Volume'



# Save the changes to ISO
New-OSDCloudISO -WorkspacePath $WorkspacePath
$FinalISO = "OSDCloud-$ProjectName.iso"
if(Test-Path "$WorkspacePath\$FinalISO"){
    Remove-Item -Path "$WorkspacePath\$FinalISO" -Force
}
Rename-Item -Path "$WorkspacePath\OSDCloud_NoPrompt.iso" -NewName "$WorkspacePath\$FinalISO" -Force

Write-Host -ForegroundColor Green "ISO created: $WorkspacePath\$FinalISO"

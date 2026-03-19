<#
.SYNOPSIS

.DESCRIPTION

.NOTES
    Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
    Version: 1.0

    Changelog:
    - 2025-02-09: 1.0 Initial version
    
#>


# Set Workspace Folder
$ProjectName = "OSDCloud-GUI"
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

# Save the changes to ISO
New-OSDCloudISO -WorkspacePath $WorkspacePath
$FinalISO = "$ProjectName.iso"
if(Test-Path "$WorkspacePath\$FinalISO"){
    Remove-Item -Path "$WorkspacePath\$FinalISO" -Force
}

Rename-Item -Path "$WorkspacePath\OSDCloud_NoPrompt.iso" -NewName "$WorkspacePath\$FinalISO" -Force
Start-Sleep -s 10

Write-Host -ForegroundColor Green "ISO created: $WorkspacePath\$FinalISO"

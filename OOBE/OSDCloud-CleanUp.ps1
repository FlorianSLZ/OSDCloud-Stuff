Start-Transcript "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\OSDCloud-CleanUp.log" | Out-Null

# Copying OSDCloud Logs
If (Test-Path -Path 'C:\OSDCloud\Logs') {
    Write-Host "Copying OSDCloud Logs"
    Move-Item 'C:\OSDCloud\Logs\*.*' -Destination 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD' -Force
}
If (Test-Path -Path 'C:\ProgramData\OSDeploy') {
    Write-Host "Copying OSDCloud Logs"
    Move-Item 'C:\ProgramData\OSDeploy\*.*' -Destination 'C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD' -Force
}

# Cleanup directories
If (Test-Path -Path 'C:\OSDCloud') { 
    Write-Host "Removing OSDCloud directory"
    Remove-Item -Path 'C:\OSDCloud' -Recurse -Force 
}
If (Test-Path -Path 'C:\Drivers') { 
    Write-Host "Removing Drivers directory"
    Remove-Item 'C:\Drivers' -Recurse -Force 
}

Stop-Transcript

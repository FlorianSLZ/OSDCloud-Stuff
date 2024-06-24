#================================================
#   [PreOS] Update Module
#================================================
#Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
#Install-Module OSD -Force

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force   

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
$Params = @{
    OSVersion = "Windows 11"
    OSBuild = "23H2"
    OSEdition = "Pro"
    OSLanguage = "de-de"
    OSLicense = "Retail"
    ZTI = $true
    Firmware = $false
}
Start-OSDCloud @Params

#================================================
#  [PostOS] SetupComplete CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
powershell.exe -Command Start-Transcript -Path "C:\Windows\Setup\Scripts\SetupComplete.log"
powershell.exe -Command Get-NetIPAddress
powershell.exe -Command Test-Connection -ComputerName raw.githubusercontent.com
powershell.exe -Command Set-ExecutionPolicy Unrestricted -Force
powershell.exe -Command "& {IEX (IRM https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/OOBE-Task.ps1)}"
powershell.exe -Command Stop-Transcript
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Green "Restarting in 10 seconds!"
Start-Sleep -Seconds 10
wpeutil reboot


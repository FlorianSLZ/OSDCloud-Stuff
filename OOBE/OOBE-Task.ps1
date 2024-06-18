Start-Transcript -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\OSDCloud-OOBE-Task.log"

$scriptFolderPath = "$env:SystemDrive\OSDCloud\Scripts"
$ScriptPathOOBE = $(Join-Path -Path $scriptFolderPath -ChildPath "OOBE.ps1")
$ScriptPathSendKeys = $(Join-Path -Path $scriptFolderPath -ChildPath "SendKeys.ps1")

If(!(Test-Path -Path $scriptFolderPath)) {
    New-Item -Path $scriptFolderPath -ItemType Directory -Force | Out-Null
}

$OOBEScript =@"
Start-Transcript -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\OSDCloud-OOBE-Actions.log"

Write-Host "Installing Language Pack: DE-DE"
Start-Process PowerShell -ArgumentList "-NoL -C Install-Language de-de" -Wait

Write-Host "Installing Language Pack: FR-FR"
Start-Process PowerShell -ArgumentList "-NoL -C Install-Language fr-fr" -Wait

Write-Host "Installing Language Pack: IT-IT"
Start-Process PowerShell -ArgumentList "-NoL -C Install-Language it-it" -Wait

Write-Host "Installing Language Pack: EN-US"
Start-Process PowerShell -ArgumentList "-NoL -C Install-Language en-us" -Wait

Write-Host "Enabling built-in Windows Producy Key"
Start-Process PowerShell -ArgumentList "-NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Set-EmbeddedWINKey.ps1" -Wait

Write-Host "Starting Windows Updates"
Start-Process PowerShell -ArgumentList "-NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Windows-Updates.ps1" -Wait

Write-Host "Executing Cleanup Script"
Start-Process PowerShell -ArgumentList "-NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/OSDCloud-CleanUp.ps1" -Wait

Write-Host "Restarting Computer"
Start-Process PowerShell -ArgumentList "-NoL -C Restart-Computer -Force" -Wait

Stop-Transcript
"@

Out-File -FilePath $ScriptPathOOBE -InputObject $OOBEScript -Encoding ascii

$SendKeysScript = @"
Start-Transcript -Path "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\OSDCloud-SendKeys.log"

Write-Host "Stop Debug-Mode (SHIFT + F10) with WscriptShell.SendKeys"
`$WscriptShell = New-Object -com Wscript.Shell

# ALT + TAB
Write-Host "SendKeys: ALT + TAB"
`$WscriptShell.SendKeys("%({TAB})")

Start-Sleep -Seconds 2

# Shift + F10
Write-Host "SendKeys: SHIFT + F10"
`$WscriptShell.SendKeys("+({F10})")

Stop-Transcript -Verbose 
"@

Out-File -FilePath $ScriptPathSendKeys -InputObject $SendKeysScript -Encoding ascii

# Download ServiceUI64.exe
Write-Host -ForegroundColor Gray "Download ServiceUI64.exe from GitHub Repo"
Invoke-WebRequest https://github.com/FlorianSLZ/OSDCloud-Stuff/raw/main/OOBE/ServiceUI64.exe -OutFile "C:\OSDCloud\ServiceUI64.exe"


#Create Scheduled Task for SendKeys with 15 seconds delay
$TaskName = "OSDCloud OOBE SendKeys"

$ShedService = New-Object -comobject 'Schedule.Service'
$ShedService.Connect()

$Task = $ShedService.NewTask(0)
$Task.RegistrationInfo.Description = $taskName
$Task.Settings.Enabled = $true
$Task.Settings.AllowDemandStart = $true
$Task.Settings.DisallowStartIfOnBatteries = $false
$Task.Settings.StopIfGoingOnBatteries = $false

# https://msdn.microsoft.com/en-us/library/windows/desktop/aa383987(v=vs.85).aspx
$trigger = $task.triggers.Create(9) # 0 EventTrigger, 1 TimeTrigger, 2 DailyTrigger, 3 WeeklyTrigger, 4 MonthlyTrigger, 5 MonthlyDOWTrigger, 6 IdleTrigger, 7 RegistrationTrigger, 8 BootTrigger, 9 LogonTrigger
$trigger.Delay = 'PT15S'
$trigger.Enabled = $true

$action = $Task.Actions.Create(0)
$action.Path = 'C:\OSDCloud\ServiceUI64.exe'
$action.Arguments = '-process:RuntimeBroker.exe C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe ' + $ScriptPathSendKeys + ' -ExecutionPolicy Bypass -NoExit'

$taskFolder = $ShedService.GetFolder("\")
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa382577(v=vs.85).aspx
$taskFolder.RegisterTaskDefinition($TaskName, $Task , 6, "SYSTEM", $NULL, 5)

# Create Scheduled Task for OSDCloud post installation with 20 seconds delay
$TaskName = "OSDCloud OOBE Script"

$ShedService = New-Object -comobject 'Schedule.Service'
$ShedService.Connect()

$Task = $ShedService.NewTask(0)
$Task.RegistrationInfo.Description = $taskName
$Task.Settings.Enabled = $true
$Task.Settings.AllowDemandStart = $true
$Task.Settings.DisallowStartIfOnBatteries = $false
$Task.Settings.StopIfGoingOnBatteries = $false


# https://msdn.microsoft.com/en-us/library/windows/desktop/aa383987(v=vs.85).aspx
$trigger = $task.triggers.Create(9) # 0 EventTrigger, 1 TimeTrigger, 2 DailyTrigger, 3 WeeklyTrigger, 4 MonthlyTrigger, 5 MonthlyDOWTrigger, 6 IdleTrigger, 7 RegistrationTrigger, 8 BootTrigger, 9 LogonTrigger
$trigger.Delay = 'PT20S'
$trigger.Enabled = $true

$action = $Task.Actions.Create(0)
$action.Path = 'C:\OSDCloud\ServiceUI64.exe'
$action.Arguments = '-process:RuntimeBroker.exe C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe ' + $ScriptPathOOBE + ' -ExecutionPolicy Bypass -NoExit'

$taskFolder = $ShedService.GetFolder("\")
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa382577(v=vs.85).aspx
$taskFolder.RegisterTaskDefinition($TaskName, $Task , 6, "SYSTEM", $NULL, 5)


Stop-Transcript

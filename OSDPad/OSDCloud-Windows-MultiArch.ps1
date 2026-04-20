<#
.SYNOPSIS
    OSDCloud Automation Script for Windows Deployment

.DESCRIPTION
    Automates the deployment of Windows 11 with specified parameters, downloads OOBE scripts, and sets up post-installation tasks.

.NOTES
    Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
    Version: 1.0

    Changelog:
    - 2026-03-19: 1.0 Initial version
    
#>
#################################################################
#   [PreOS 1/2] Check Internet Connectio
#################################################################
Write-Host "Checking Internet Connection..."

$NetworkCheck = "powershellgallery.com"
$TimeoutInSeconds = 120 # 2 minutes
$ElapsedTime = 0
$SleepTime = 5

while (-not (Test-Connection $NetworkCheck -Count 1 -Quiet) -and ($ElapsedTime -lt $TimeoutInSeconds)) {
    Start-Sleep -Seconds $SleepTime
    $ElapsedTime += $SleepTime
}

if ($ElapsedTime -ge $TimeoutInSeconds) {
    Write-Error "Timeout reached after 2 minutes without a connection." 
    Write-Host "Try running the process manually once the internet connection is established." -ForegroundColor Cyan
    Write-Host "    Install-Module OSDCloud"
    Write-Host "    Deploy-OSDCloud"
    exit 1
} else {
    Write-Host "Internet connection established after $ElapsedTime seconds." -ForegroundColor Green
}

#################################################################
#   [PreOS 2/2] Update Module
#################################################################
Write-Host -ForegroundColor Green "Installing OSDCloud PowerShell Module"
Install-Module OSDCloud -Force

Write-Host  -ForegroundColor Green "Importing OSDCloud PowerShell Module"
Import-Module OSDCloud -Force   

#################################################################
#   [OS] Start Deployment UI
#################################################################
Invoke-RestMethod 'https://deploy.osdcloud.live' | Invoke-Expression


#################################################################
#   [PostOS] Restart-Computer
#################################################################
10..1 | ForEach-Object{
    Write-Progress -Activity "Computer Restart" -Status "in $_ seconds"
    Start-Sleep -seconds 1
 }
Restart-Computer -Force


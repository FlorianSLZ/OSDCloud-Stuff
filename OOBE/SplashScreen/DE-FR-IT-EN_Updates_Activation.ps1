<#
.SYNOPSIS
    Displays a Splash Screen to Installs the latest Windows 10/11 quality updates + activates Windows. 

.NOTES
    Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
    Version: 1.3

    Changelog:
    - 2024-08-15: 1.0 Initial version
    - 2024-08-19: 1.1 Added reboot with 20s dealy
    - 2024-08-19: 1.2 Added Internet Connection Check
    - 2025-03-04: 1.3 Added simple Transcript and PSGallery check


#>

Start-Transcript -Path "$PSScriptRoot\DE-FR-IT-EN_Updates_Activation.log" -Append

$Scripts2run = @(
  @{
    Name = "Enabling built-in Windows Producy Key"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Set-EmbeddedWINKey.ps1"
  },
  @{
    Name = "Windows Quality Updates"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Windows-Updates_Quality.ps1"
  },
  @{
    Name = "Windows Firmware and Driver Updates"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Windows-Updates_DriverFirmware.ps1"
  },
  @{
    Name = "Language Installation: German"
    Script = "Install-Language de-de"
  },
  @{
    Name = "Language Installation: French"
    Script = "Install-Language fr-fr"
  },
  @{
    Name = "Language Installation: Italian"
    Script = "Install-Language it-it"
  },
  @{
    Name = "Language Installation: English"
    Script = "Install-Language en-us"
  },
  @{
    Name = "Saving Logs and Cleanup"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/OSDCloud-CleanUp.ps1"
  },
  @{
    Name = "Sending Reboot Command"
    Script = "shutdown.exe -r -f -t 20"
  }
)

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
    exit 1
} else {
    Write-Host "Internet connection established after $ElapsedTime s." -ForegroundColor Green
}


Write-Host "Starting Windows Updates, Activation and installation of additional languages..."

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
Install-PackageProvider -Name NuGet -Force | Out-Null

if($(Get-PSRepository).Name -notcontains "PSGallery") {
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
  Register-PSRepository -Default -Verbose
  Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}
Install-Script Start-SplashScreen -Force | Out-Null

Start-SplashScreen.ps1 -Processes $Scripts2run


Stop-Transcript
<#
.SYNOPSIS
    Displays a Splash Screen to Installs the latest Windows 10/11 quality updates + activates Windows. 

.NOTES
    Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
    Version: 1.0

    Changelog:
    - 2024-08-15: 1.0 Initial version

#>
$Scripts2run = @(
  @{
    Name = "Enabling built-in Windows Producy Key"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Set-EmbeddedWINKey.ps1"
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
    Name = "Windows Quality Updates"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Windows-Updates_Quality.ps1"
  },
  @{
    Name = "Windows Firmware and Driver Updates"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Windows-Updates_DriverFirmware.ps1"
  },
  @{
    Name = "Saving Logs and Cleanup"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/OSDCloud-CleanUp.ps1"
  }
)

Write-Host "Starting Windows Updates and Activation"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Script Start-SplashScreen -Force | Out-Null

Start-SplashScreen.ps1 -Processes $Scripts2run

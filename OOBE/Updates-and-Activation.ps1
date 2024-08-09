<#
.SYNOPSIS
    Displays a Splash Screen to Installs the latest Windows 10/11 quality updates + activates Windows. 

.NOTES
    FileName:    Updates-and-Activation.ps1
    Author:      Florian Salzmann
    Created:     2024-08-09
    Updated:     2024-08-09

    Version history:
    1.0.0   -   (2024-08-09) Script created
#>
$Scripts2run = @(
  @{
    Name = "Enabling built-in Windows Producy Key"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Set-EmbeddedWINKey.ps1"
  },
  @{
    Name = "Windows Updates"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/Windows-Updates.ps1"
  },
  @{
    Name = "Saving Logs and Cleanup"
    Script = "https://raw.githubusercontent.com/FlorianSLZ/OSDCloud-Stuff/main/OOBE/OSDCloud-CleanUp.ps1"
  }
)

Install-PackageProvider -Name NuGet -Force
Install-Script Start-SplashScreen -Force
Start-SplashScreen.ps1 -Processes $Scripts2run


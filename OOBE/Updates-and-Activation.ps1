<#
.SYNOPSIS
    Displays a Splash Screen to Installs the latest Windows 10/11 quality updates + activates Windows. 

.NOTES
    FileName:    Updates-and-Activation.ps1
    Author:      Florian Salzmann
    Created:     2024-08-09
    Updated:     2024-08-14

    Version history:
    1.0 - (2024-08-09) Script created
    1.1 - (2024-08-14) TLS 1.2 added/forced

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

Write-Host "Starting Windows Updates and Activation 3"
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Updates-and-Activation.log" -Force | Out-Null

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module PowerShellGet -RequiredVersion 2.2.4 -SkipPublisherCheck -Force

Install-Script Start-SplashScreen -Force | Out-Null
Start-SplashScreen.ps1 -Processes $Scripts2run

Stop-Transcript

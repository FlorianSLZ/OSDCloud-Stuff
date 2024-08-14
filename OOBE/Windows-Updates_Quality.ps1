<#
.SYNOPSIS
    Installs the latest Windows 10/11 quality updates and adds Language packs: EN, DE, FR, and IT.

.NOTES
    FileName:    Windows-Updates_Quality.ps1
    Author:      Florian Salzmann
    Created:     2024-08-14
    Updated:     2024-08-14

    Version history:
        2024-08-14, 1.0:    Script created.

#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $False)] 
    [ValidateSet('Soft', 'Hard', 'None', 'Delayed')] 
    [String] $Reboot = 'None',
    
    [Parameter(Mandatory = $False)] 
    [Int32] $RebootTimeout = 10 # seconds
)

Process {

    # If running as a 32-bit process on an x64 system, re-launch as a 64-bit process
    if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64" -and (Test-Path "$env:WINDIR\SysNative\WindowsPowerShell\v1.0\powershell.exe")) {
        & "$env:WINDIR\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -Reboot $Reboot -RebootTimeout $RebootTimeout
        Exit $lastexitcode
    }

    # Start logging
    Start-Transcript "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Windows-QualityUpdates.log" | Out-Null

    Write-Host "Installing Windows Quality Updates ..."

    # Opt into Microsoft Update
    $ts = Get-Date -Format "yyyy/MM/dd hh:mm:ss tt"
    Write-Output "$ts Opting into Microsoft Update"
    $ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
    $ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
    $ServiceManager.AddService2($ServiceId, 7, "") | Out-Null

    # Install available quality updates
    $WUDownloader = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
    $WUInstaller = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
    $queries = @("IsInstalled=0 and Type='Software'")

    $queries | ForEach-Object {
        $WUUpdates = New-Object -ComObject Microsoft.Update.UpdateColl
        Write-Host "$ts Getting quality updates."
        
        (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher().Search($_).Updates | ForEach-Object {
            if (!$_.EulaAccepted) { $_.EulaAccepted = $true }
            if ($_.Title -notmatch "Preview") { [void]$WUUpdates.Add($_) }
        }

        if ($WUUpdates.Count -ge 1) {
            $WUInstaller.ForceQuiet = $true
            $WUInstaller.Updates = $WUUpdates
            $WUDownloader.Updates = $WUUpdates
            
            if ($WUDownloader.Updates.Count -ge 1) {
                Write-Output "$ts Downloading updates"
                $Download = $WUDownloader.Download()
                Write-Verbose $Download
            }
            if ($WUInstaller.Updates.Count -ge 1) {
                Write-Output "$ts Installing updates"
                $Install = $WUInstaller.Install()
                $script:needReboot = $Install.RebootRequired
            } 
        } else {
            Write-Output "No Quality Updates Found"
        } 
    }

    # Reboot handling
    $ts = Get-Date -Format "yyyy/MM/dd hh:mm:ss tt"
    if ($script:needReboot) {
        Write-Host "$ts Windows Update indicated that a reboot is needed."
    } else {
        Write-Host "$ts Windows Update indicated that no reboot is required."
    }

    if ($Reboot -eq "Hard") {
        Write-Host "$ts Exiting with return code 1641 to indicate a hard reboot is needed." -ForegroundColor Cyan
        Stop-Transcript
        #Exit 1641
    } elseif ($Reboot -eq "Soft") {
        Write-Host "$ts Exiting with return code 3010 to indicate a soft reboot is needed." -ForegroundColor Cyan
        Stop-Transcript
        #Exit 3010
    } elseif ($Reboot -eq "Delayed") {
        Write-Host "$ts Rebooting with a $RebootTimeout second delay" -ForegroundColor Cyan
        & shutdown.exe /r /t $RebootTimeout /c "Rebooting to complete the installation of Windows updates." 
        Exit 0
    } else {
        Write-Host "$ts Skipping reboot based on Reboot parameter (None)" -ForegroundColor Cyan
        #Exit 0
    }
}

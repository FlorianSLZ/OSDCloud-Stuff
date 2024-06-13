<#
.SYNOPSIS
    Installs the latest Windows 10/11 quality updates + adds Language packs: EN, DE, FR and IT 

.NOTES
    FileName:    Windows-Updates&Language.ps1
    Author:      Florian Salzmann
    Created:     2024-06-04
    Updated:     2024-06-04

    Version history:
    1.0.0   -   (2024-06-04) Script created
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $False)] 
    [array] $Languages = @('de-de', 'fr-fr', 'it-it', 'en-us'),
    
    [Parameter(Mandatory = $False)] 
    [ValidateSet('Soft', 'Hard', 'None', 'Delayed')] 
    [String] $Reboot = 'None',
    
    [Parameter(Mandatory = $False)] 
    [Int32] $RebootTimeout = 10, # seconds
    
    [Parameter(Mandatory = $False)] 
    [switch] $ExcludeDrivers,
    
    [Parameter(Mandatory = $False)] 
    [switch] $ExcludeUpdates
)

Process {

    # If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
    if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
        if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
            if ($ExcludeDrivers) {
                & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -Reboot $Reboot -RebootTimeout $RebootTimeout -ExcludeDrivers
            } elseif ($ExcludeUpdates) {
                & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -Reboot $Reboot -RebootTimeout $RebootTimeout -ExcludeUpdates
            } else {
                & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath" -Reboot $Reboot -RebootTimeout $RebootTimeout
            }
            Exit $lastexitcode
        }
    }


    # Start logging
    Start-Transcript "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\Windows-Updates.log"

    if($(Test-NetConnection microsoft.com -CommonTCPPort "Http" -ErrorAction SilentlyContinue).TcpTestSucceeded -ne $true){
        Write-Error "No Internet Connection!"
        exit 1
    }



    #############################################
    #               Windows Updates             #
    #############################################
    Write-Host "Installing Windows Updates ..."

    # Main logic
    $script:needReboot = $false

    # Opt into Microsoft Update
    $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
    Write-Output "$ts Opting into Microsoft Update"
    $ServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager"
    $ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
    $ServiceManager.AddService2($ServiceId, 7, "") | Out-Null

    # Install all available updates
    $WUDownloader = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
    $WUInstaller = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
    if ($ExcludeDrivers) {
        # Updates only
        $queries = @("IsInstalled=0 and Type='Software'")
    }
    elseif ($ExcludeUpdates) {
        # Drivers only
        $queries = @("IsInstalled=0 and Type='Driver'")
    } else {
        # Both
        $queries = @("IsInstalled=0 and Type='Software'", "IsInstalled=0 and Type='Driver'")
    }

    $queries | ForEach-Object {

        $WUUpdates = New-Object -ComObject Microsoft.Update.UpdateColl
        $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
        Write-Host "$ts Getting $_ updates."        
        ((New-Object -ComObject Microsoft.Update.Session).CreateupdateSearcher().Search($_)).Updates | ForEach-Object {
            if (!$_.EulaAccepted) { $_.EulaAccepted = $true }
            if ($_.Title -notmatch "Preview") { [void]$WUUpdates.Add($_) }
        }

        if ($WUUpdates.Count -ge 1) {
            $WUInstaller.ForceQuiet = $true
            $WUInstaller.Updates = $WUUpdates
            $WUDownloader.Updates = $WUUpdates
            $UpdateCount = $WUDownloader.Updates.count
            if ($UpdateCount -ge 1) {
                $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
                Write-Output "$ts Downloading $UpdateCount Updates"
                foreach ($update in $WUInstaller.Updates) { Write-Output "$($update.Title)" }
                $Download = $WUDownloader.Download()
            }
            $InstallUpdateCount = $WUInstaller.Updates.count
            if ($InstallUpdateCount -ge 1) {
                $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
                Write-Output "$ts Installing $InstallUpdateCount Updates"
                $Install = $WUInstaller.Install()
                $ResultMeaning = ($Results | Where-Object { $_.ResultCode -eq $Install.ResultCode }).Meaning
                Write-Output $ResultMeaning
                $script:needReboot = $Install.RebootRequired
            } 
        }
        else {
            Write-Output "No Updates Found"
        } 
    }

    # Specify return code
    $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
    if ($script:needReboot) {
        Write-Host "$ts Windows Update indicated that a reboot is needed."
    }
    else {
        Write-Host "$ts Windows Update indicated that no reboot is required."
    }

    # For whatever reason, the reboot needed flag is not always being properly set.  So we always want to force a reboot.
    # If this script (as an app) is being used as a dependent app, then a hard reboot is needed to get the "main" app to install.
    $ts = get-date -f "yyyy/MM/dd hh:mm:ss tt"
    if ($Reboot -eq "Hard") {
        Write-Host "$ts Exiting with return code 1641 to indicate a hard reboot is needed." -ForegroundColor Cyan
        Stop-Transcript
        #Exit 1641
    }
    elseif ($Reboot -eq "Soft") {
        Write-Host "$ts Exiting with return code 3010 to indicate a soft reboot is needed." -ForegroundColor Cyan
        Stop-Transcript
        #Exit 3010
    }
    elseif ($Reboot -eq "Delayed") {
        Write-Host "$ts Rebooting with a $RebootTimeout second delay" -ForegroundColor Cyan
        & shutdown.exe /r /t $RebootTimeout /c "Rebooting to complete the installation of Windows updates." 
        Exit 0
    }
    else {
        Write-Host "$ts Skipping reboot based on Reboot parameter (None)" -ForegroundColor Cyan
        #Exit 0
    }


}

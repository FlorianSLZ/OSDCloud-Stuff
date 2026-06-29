<#
.SYNOPSIS
    OSDCloud Automation Script for Windows Deployment

.DESCRIPTION
    Automates the deployment of Windows 11 with specified parameters, downloads OOBE scripts, and sets up post-installation tasks.

.NOTES
    Author: Florian Salzmann | @FlorianSLZ | https://scloud.work
    Version: 1.0

    Changelog:
    - 2026-06-29: 1.0 Initial version

    
#>
    
#################################################################
#   [OS] Bootstrap deploy.osdcloud.live
#################################################################
Invoke-RestMethod 'https://deploy.osdcloud.live' | Invoke-Expression
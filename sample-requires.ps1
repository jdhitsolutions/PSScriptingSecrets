#requires -version 5.0
#requires -module SMBshare
#requires -RunAsAdministrator

Write-Host "Starting my script" -ForegroundColor green

Get-SmbShare -Name Scripts


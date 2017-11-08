
. $PSScriptRoot\functions.ps1

Set-alias -Name gos -Value Get-OS
Set-Alias -Name gsi -Value Get-SysInfo
$DemoLocation = "Orlando"

$F = "Get-OS","Get-SysInfo"
$A = "gos","gsi"
$V = 'DemoLocation'

Export-ModuleMember -Function $F -Alias $A -Variable $V
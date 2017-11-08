#requires -version 5.1

Return "This is a walkthrough demo"

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.NOTES
Version: 0.0
.LINK

#>
Function Get-StartName {

[CmdletBinding()]

Param
(
[Parameter(Mandatory,ValueFromPipelineByPropertyName,ValueFromPipeline,Position=0)]
[String[]]$Name
)

Begin {
    Write-Verbose "Starting $($MyInvocation.Mycommand)"  

} #begin

Process {
    Get-Service -name WinRM -ComputerName $name

} #process

End {

    Write-Verbose "Ending $($MyInvocation.Mycommand)"
} #end

} #close function

$n = "bits","spooler","winrm"
Get-StartName $n
$n | get-startname

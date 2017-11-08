#requires -version 5.0

Return "This is a walkthrough demo"

Function Get-EventLogData {

[cmdletbinding()]
Param(
[string]$Eventlog,
[string[]]$Type="Error",
[Datetime]$Cutoff,
[string]$Computername = $env:COMPUTERNAME
)

Write-Verbose "Getting $($entrytype -join ',') entries from $eventlog on $computername after $cutoff"
Try {
    get-Eventlog -LogName $Eventlog -EntryType $Type -After $Cutoff -Computername $Computername -erroraction Stop
}
Catch {
    Throw $_
}

}

Get-eventlogdata -Eventlog system -cutoff (Get-Date).AddDays(-7) -Verbose | 
Select -first 3 TimeGenerated,Source,EntryType,Message

Function Get-EventLogData2 {

[cmdletbinding()]
Param(
[string]$Eventlog,
[string[]]$Type="Error",
[Datetime]$Cutoff,
[string]$Computername = $env:COMPUTERNAME
)

Write-Verbose "Getting $($entrytype -join ',') entries from $eventlog on $computername after $after"

#hash table of parameters to splat
$params = @{
    LogName = $Eventlog 
    EntryType = $Type
    After = $Cutoff 
    Computername = $Computername
    erroraction = 'Stop'
}

Try {
    get-Eventlog @params
}
Catch {
    Throw $_
}

}

Get-eventlogdata2 -Eventlog system -cutoff (Get-Date).AddDays(-3) -Verbose | 
Select -first 3 TimeGenerated,Source,EntryType,Message


#using PSBoundParameters
Function Get-EventLogData3 {

[cmdletbinding()]
Param(
[Alias("eventlog")]
[string]$LogName,
[alias("type")]
[string[]]$EntryType="Error",
[Alias("Cutoff")]
[Datetime]$After,
[string]$Computername = $env:COMPUTERNAME
)

Write-Verbose "Getting $($entrytype -join ',') entries from $Logname on $computername after $after"
write-verbose ($psboundparameters | out-string)

#hash table of parameters to splat
$psboundparameters.add("ErrorAction","Stop")

Try {
    get-Eventlog @psboundparameters
}
Catch {
    Throw $_
}

}

#this doesn't quite work - notice the entrytype
Get-eventlogdata3 -Eventlog system -cutoff (Get-Date).AddDays(-3) -Verbose | 
Select -first 3 TimeGenerated,Source,EntryType,Message

Function Get-EventLogData4 {

[cmdletbinding()]
Param(
[Alias("eventlog")]
[string]$LogName,
[alias("type")]
[string[]]$EntryType="Error",
[Alias("Cutoff")]
[Datetime]$After,
[string]$Computername = $env:COMPUTERNAME
)

Write-Verbose "Getting $($entrytype -join ',') entries from $Logname on $computername after $after"
write-verbose ($psboundparameters | out-string)

#hash table of parameters to splat
$psboundparameters.add("ErrorAction","Stop")

#add the default value
if (-Not $psboundparameters.ContainsKey("EntryType")) {
    $psboundparameters.add("EntryType",$EntryType)
}

#you can also remove entries from PSBoundParameters

Try {
    get-Eventlog @psboundparameters
}
Catch {
    Throw $_
}

}

#note that I can still use aliases
Get-eventlogdata4 -Eventlog system -cutoff (Get-Date).AddDays(-3) -Verbose | 
Select -first 3 TimeGenerated,Source,EntryType,Message


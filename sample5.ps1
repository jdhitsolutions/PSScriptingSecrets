
Return "Haven't you figured out this is a walkthrough by now?!"

Function Get-EventLogData5 {

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

$list = Get-eventlog -list -ComputerName $Computername
if ($list.logdisplayname -notcontains $Logname) {
    Write-warning "Oops: $Logname doesn't look like a valid log."
    #bail out
    Return
}

Write-Verbose "Getting $($entrytype -join ',') entries from $Logname on $computername after $after"
write-verbose ($psboundparameters | out-string)

#hash table of parameters to splat
$psboundparameters.add("ErrorAction","Stop")

#add the default value
if (-Not $psboundparameters.ContainsKey("EntryType")) {
    $psboundparameters.add("EntryType",$EntryType)
}

Try {
    get-Eventlog @psboundparameters
}
Catch {
    Throw $_
}

}

Get-EventLogData5 -LogName foo
Get-EventLogData5 -LogName system -EntryType errror

Function Get-EventLogData6 {

[cmdletbinding()]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter the name of an event log")]
[Alias("eventlog")]
[ValidateSet("System","Application","Security","Windows PowerShell")]
[string]$LogName,
[alias("type")]
[ValidateSet("Error","Warning","Information","FailureAudit","SuccessAudit")]
[string[]]$EntryType="Error",
[Alias("Cutoff")]
[ValidateScript({$_ -le (Get-Date)})]
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

Try {
    get-Eventlog @psboundparameters
}
Catch {
    Throw $_
}

}

Get-eventlogdata6 foo

Get-EventLogData6 -LogName Application -EntryType Error,Warning -After (Get-Date).AddDays(-3)

#handle your own validation failures
#you can have multiple validations
Function Get-EventLogData7 {

[cmdletbinding()]
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter the name of an event log")]
[Alias("eventlog")]
[ValidateSet("System","Application","Security","Windows PowerShell")]
[ValidateScript({
 $list = "System","Application","Security","Windows PowerShell"
 if ($list -contains $_) {
    $True
 }
 else {
   Throw "You entered an incorrect log name. Valid entries are $($list -join ',')"

 }
})]
[string]$LogName,
[alias("type")]
[ValidateSet("Error","Warning","Information","FailureAudit","SuccessAudit")]
[string[]]$EntryType="Error",
[Alias("Cutoff")]
[ValidateScript({$_ -le (Get-Date)})]
[Datetime]$After,
[Alias("cn")]
[ValidateNotNullorEmpty()]
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

Try {
    get-Eventlog @psboundparameters
}
Catch {
    Throw $_
}

}

Get-EventLogData7 -LogName foo

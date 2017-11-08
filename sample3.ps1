#requires -module SMBShare

Return "This is a walkthrough demo"

#be sure to document
Function Get-ShareData {
[cmdletbinding()]

Param(
[string]$Name,
[string]$Computername = $env:COMPUTERNAME
)

#save existing value if found
if ($PSDefaultParameterValues.ContainsKey("Write-Host:foregroundcolor")) {
    $saved = $PSDefaultParameterValues."Write-host:foregroundcolor"
}

$PSDefaultParameterValues.Add("Write-Host:foregroundcolor","cyan")

write-Host "Getting share $Name from $computername"

$share = Get-SMBShare -Name $Name -CimSession $Computername
$sharepath = $share.path

write-host "Measuring files in $sharePath"

$stats = Invoke-Command { 
get-childitem -path $using:sharepath -file -Recurse |
Measure-Object -Property length -sum
} -computername $Computername

Write-Host "Found $($stats.count) files"

[pscustomobject]@{
    Name = $share.Name
    Description = $share.Description
    Path = $Sharepath
    Files = $stats.count
    Size = $stats.Sum
    Date = (Get-Date).ToShortDateString()
    Computername = $share.pscomputername.toUpper()
}

if ($saved) {
    $PSDefaultParameterValues."Write-host:foregroundcolor" = $saved
}
else {
    $PSDefaultParameterValues.remove("Write-host:foregroundcolor")
}

} #close function

$PSDefaultParameterValues.Clear()
$PSDefaultParameterValues

Get-ShareData -Name Work -Computername bovine320

$PSDefaultParameterValues

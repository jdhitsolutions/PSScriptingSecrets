<#
In this session longtime PowerShell MVP and sensei Jeff Hicks will share some of 
his scripting secrets. Some of them are simple tips that might make your code 
more manageable. Others might yield great performance benefits. Whether you are
just beginning with PowerShell or a veteran scripter there should be a secret 
worth knowing for everybody.

It is assumed you will be using the PowerShell ISE to run these demos.
#>

#region use a PowerShell-aware editor
notepad .\sample.ps1

psedit .\sample.ps1

#assumes you have VS Code installed
code .\sample.ps1

#endregion

#region use requires statements
psedit .\sample-requires.ps1

help about_requires -ShowWindow

#endregion

#region long pipeline vs several steps

measure-command {
dir ~\Documents -Directory | foreach { $stats = dir $_.fullname -Recurse -File | Measure-Object length -sum ; $_ | Select-Object Fullname,@{Name="Size";Expression={$stats.sum}},@{Name="Files";Expression={$stats.count}}} | Sort Size 
}

#you don't always need a one line command
Measure-command {

$folders = dir ~\Documents -Directory 

$data = $folders | foreach {
$stats = dir $_.fullname -Recurse -File | Measure-Object length -sum
$_ | Select-Object Fullname,@{Name="Size";Expression={$stats.sum}},
@{Name="Files";Expression={$stats.count}} 
}

$data | Sort Size

}

#or try a variation. 
#breaking it up also allows for more options
Measure-Command {

$folders = dir ~\Documents -Directory
Write-Verbose "Found $($folders.count) top level folders"
$data = foreach ($item in $folders) {
Write-Verbose "Analyzing $($item.fullname)"
 $stats = dir $item.fullname -Recurse -file | measure-object length -sum
 Write-Verbose "Found $($stats.count) files"
 [pscustomobject]@{
   Path = $item.fullname
   Size = $stats.Sum
   Files = $stats.count
 }
}
$data | sort Size

}

#or think outside the box
#not necessarily faster
measure-command {

$path = Convert-Path ~\documents
$grouped = dir $Path -file -recurse | group {
 $rxpath = $path.replace("\","\\")
 [regex]$rx="^$rxpath\\\w+((\s\w+)?)*(?=\\)"
 $rx.match($_.fullname).Value
}

$data = $grouped.where({$_.name}) | foreach {
 $stats = $_.group | measure-object length -sum
 $_ | Select Name,@{Name="Size";Expression={$stats.sum}},Count
} 

$data | sort Size

}


#endregion

#region Splatting with hash tables

psedit .\sample2.ps1

#endregion

#region create [pscustomobject] instead of Select-object with hashtables

Measure-Command {

Get-Ciminstance -ClassName win32_logicalDisk -filter "DriveType=3" |
Select DeviceID,VolumeName,@{Name="SizeGB";Expression={$_.size/1GB -as [int]}},
@{Name="FreeGB";expression={[math]::Round($_.freespace/1gb,4)}},
@{Name="PctFree";Expression={[math]::Round(($_.freespace/$_.size)*100,2)}},
@{Name="DiskPartition";Expression={($_ | Get-CimAssociatedInstance -ResultClassName win32_diskpartition).type }},
@{Name="Drive";Expression= {($_ | Get-CimAssociatedInstance -ResultClassName win32_diskpartition | Get-CimAssociatedInstance -ResultClassName win32_diskdrive).Model}},
@{Name="Computername";Expression={$_.SystemName}}

}

#we can also tweak performance by only getting the properties we need
Measure-command {

$p = @{
    ClassName = 'win32_logicalDisk'
    filter = "DriveType=3" 
    Property = "DeviceID","Size","Freespace","VolumeName","SystemName"
}

$disks = Get-Ciminstance @p
foreach ($disk in $disks) {
[pscustomobject]@{
    DeviceID = $disk.deviceID
    VolumeName = $disk.volumeName
    SizeGB = $disk.size/1GB -as [int]
    FreeGB = [math]::Round($disk.freespace/1gb,4)
    PctFree = [math]::round(($disk.freespace/$disk.size)*100,2)
    DiskPartition = ($disk | Get-CimAssociatedInstance -ResultClassName win32_diskpartition).type
    Drive = ($disk | Get-CimAssociatedInstance -ResultClassName win32_diskpartition | Get-CimAssociatedInstance -ResultClassName win32_diskdrive).Model
    Computername = $disk.SystemName
  }
 } #foreach

}

#you might also consider using a PowerShell class

#endregion

#region setting psdefaultparametervalues in a function

psedit .\sample3.ps1

#endregion

#region write-progress vs write-host

psedit .\sample4.ps1
psedit S:\Demo-WriteProgress.ps1

#endregion

#region set-content vs out-file vs [system.io.file]

Measure-Command {
1..500 | out-file .\scratch-outfile.txt
}
Measure-command {
1..500 | Set-Content -Path .\scratch-content.txt
}
Measure-Command {
$p = join-path (convert-path .) -ChildPath scratch-io.txt
$f = [System.IO.StreamWriter]::new($p)
1..500 | foreach { $f.WriteLine($_)}
$f.Close()
}

dir scratch*.txt
dir scratch*.txt | foreach { psedit $_.fullname}

del scratch*.txt

get-process | out-file .\scratch-ps.txt
get-process | Set-Content -path .\scratch-ps2.txt

psedit .\scratch-ps.txt
#check this
psedit .\scratch-ps2.tx
get-process | out-string | set-Content -path .\scratch-ps3.txt
psedit .\scratch-ps3.txt

dir scratch-ps*

#fun options
set-content -Path .\scratch.txt -Value $env:computername -Stream Source
get-eventlog -list | out-string | add-content .\scratch.txt
get-content scratch.txt
get-content scratch.txt -stream source

del scratch*.txt

#endregion

#region alias parameters

psedit .\sample2.ps1

#endregion

#region parameter validation vs inline
psedit .\sample5.ps1

#endregion

#region use of Write-Verbose messages

psedit .\sample6.ps1

#endregion

#region code commenting including closing brace

psedit .\sample6.ps1

#endregion

#region use templates and snippets

#this can very based on your editor of choice
get-command -noun IseSnippet

#here's how I use snippets in the PowerShell ISE
psedit .\scratch.ps1

#endregion

#region foreach-object vs foreach

Measure-Command {
dir c:\scripts -Directory | foreach-object {
$stats = (dir $_.fullname -file -Recurse | Measure-Object -Property length -sum)
 [pscustomobject]@{
    Path = $_.FullName
    Files = $stats.count
    Size = $stats.sum
 }
} | Sort Size -Descending | Select -First 5
}

#challenges with ForEach
Measure-Command {
$dirs = dir c:\scripts -Directory
foreach ($dir in $dirs) {
    $stats = (dir $dir.fullname -file -Recurse | Measure-Object -Property length -sum)
 [pscustomobject]@{
    Path = $dir.FullName
    Files = $stats.count
    Size = $stats.sum
 }
} | sort Size -Descending | Select -First 5

}

Measure-Command {
$dirs = dir c:\scripts -Directory
$data = foreach ($dir in $dirs) {
    $stats = (dir $dir.fullname -file -Recurse | Measure-Object -Property length -sum)
 [pscustomobject]@{
    Path = $dir.FullName
    Files = $stats.count
    Size = $stats.sum
 }
} 
$data| sort Size -Descending | Select -First 5

}

#endregion

#region module single psm1 vs multiple files?
cd .\DemoModule
dir | foreach { psedit $_.fullname}

#endregion

#region module export module members AND use a manifest

import-module .\DemoModule.psd1 -force
get-command -Module DemoModule
get-module DemoModule | select exported*

gsi localhost
#modify module files and try again

Remove-module DemoModule

#endregion

#region Platyps for documentation

import-module .\DemoModule.psd1 -force
help Get-SysInfo

#install-module platyps
import-module platyps
get-command -Module platyps

New-MarkdownHelp -Module DemoModule -OutputFolder .\docs -force
dir .\docs | foreach {psedit $_.FullName}

New-ExternalHelp -Path .\docs -OutputPath .\en-us -Force
help Get-SysInfo
help get-os -full

#reset demo
# dir .\docs | del
# dir .\en-us | del

#endregion
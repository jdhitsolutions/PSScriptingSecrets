#requires -version 4.0

Function Test-Subnet {

<#
.SYNOPSIS
Ping addresses in an IP subnet
.DESCRIPTION
This command is a wrapper for Test-Connection. It will ping an IP subnet range and return a custom object for each address indicating if the address responded to a ping.

IPAddress      : 172.16.10.1
Hostname       : 
Pinged         : True
TTL            : 80
Buffersize     : 32
Delay          : 1
TestDate       : 4/25/2017 9:53:08 AM
PSComputerName : JHDESK19

By default the command pings all hosts from 1 to 254 on the specfied subnet. 
Enter the subnet value like this: 172.16.10.0.

You can optionally choose to resolve the IP address to a hostname using DNS with a last resort, if that fails, to use NETBIOS.

.PARAMETER Subnet
The IP subnet such as 192.168.10.0. A regular expression pattern will validate the subnet value.
.PARAMETER Range
The range of host IP addresses. The default is 1..254.
.PARAMETER Count
The number of pings to send. The default is 1. The most you can send with this command is 10.
.PARAMETER Delay
The delay between pings in seconds. The default is 1. The maximum value is 60.
.PARAMETER Buffer
Specifies the size, in bytes, of the buffer sent with this command. The buffer default is 32.
.PARAMETER TTL
Specifies the maximum time, in seconds, that each echo request packet ("pings") is active. The default value is 80 (seconds). 
.PARAMETER AsJob
Run the command as a background job.
.PARAMETER Resolve
Resolve the DNS host name if the computer can be pinged.
.PARAMETER UseNBT
If the host name cannot be resolved using DNS, attempt to resolve using NETBIOS and the NBTSTAT command.
.PARAMETER Computername
Test the subnet from a remote computer. The default is the local host. The remote computer should be running PowerShell v3 or later but it is not required as long as remoting is enabled.
.EXAMPLE
PS C:\> Test-Subnet 192.168.10.0
Ping all computers in the 192.168.10 subnet.
.EXAMPLE
PS C:\> Test-Subnet -subnet 192.168.10.0 -range (100..200) -asjob
Ping computers 192.168.10.100 through 192.168.10.200 and run the command as a background job.
.NOTES
NAME        :  Test-Subnet
VERSION     :  4.0   
LAST UPDATED:  7 November 2017
AUTHOR      :  Jeffery Hicks (@JeffHicks)

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************

Originally published:
 http://jdhitsolutions.com/blog/2011/11/ping-ip-range/
 v2 published at http://jdhitsolutions.com/blog/2014/04/test-subnet-with-powershell/

.LINK
Test-Connection 
.INPUTS
None
.OUTPUTS
Custom object
#>

    [cmdletbinding(DefaultParameterSetName = "NoResolve")]

    Param (
        [Parameter(Position = 0)]
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.0")]
        [string]$Subnet = "172.16.10.0",
        [Parameter(Position = 1)]
        [ValidateRange(1, 254)]
        [int[]]$Range = 1..254,
        [ValidateRange(1, 10)]
        [int]$Count = 1,
        [ValidateRange(1, 60)]
        [int]$Delay = 1,
        [ValidateScript( {$_ -ge 1})]
        [int]$Buffer = 32,
        [ValidateScript( {$_ -ge 1})]
        [int]$TTL = 80,
        [Switch]$AsJob,
        [Parameter(ParameterSetName = "Resolve")]
        [Switch]$Resolve,
        [Parameter(ParameterSetName = "Resolve")]
        [Switch]$UseNBT,
        [ValidateNotNullorEmpty()]
        [string[]]$Computername = $env:COMPUTERNAME
    )

    Write-Verbose "Testing $subnet"
    #define a scriptblock so we can run as a job if necessary
    $sb = {
        #define some variables for Write-Progress
        $progHash = @{
            Activity         = "Test Subnet $($using:subnet) from $($env:computername)"
            Status           = "Pinging"
            CurrentOperation = $Null
            PercentComplete  = 0
        }

        Write-Progress @progHash

        $i = 0
        $total = ($using:Range).count

        Foreach ($node in ($using:range)) {

            $i++
    
            $progHash.PercentComplete = ($i / $total) * 100

            #replace the 0 with the range number
            $target = ([regex]"0$").replace($using:subnet, $node)

            $progHash.CurrentOperation = $target
            Write-Progress @progHash
    
            #define a hashtable of paramters to splat to Test-Connection
            $pingHash = @{
                ComputerName = $target
                count        = $using:count
                Delay        = $using:delay
                BufferSize   = $using:Buffer
                TimeToLive   = $using:ttl
                Quiet        = $True
            }

            $ping = Test-Connection @pingHash 
    
            if ($ping -AND $using:resolve) {
                $progHash.status = "Resolving host name"
                Write-Progress @progHash
                <#
            using .NET because there's no guarantee remote computers
            will have the necessary cmdlets, and this should also be
            slightly faster.
            #>
                $Hostname = [system.net.dns]::Resolve("$target").hostname

                if ($UseNBT -AND ($hostname -eq $target)) {
                    Write-verbose "Resolving with NBTSTAT"
                    [regex]$rx = "(?<Name>\S+)\s+<00>\s+UNIQUE"                                                              
                    $nbt = nbtstat -A $target | out-string
                    $Hostname = $rx.Match($nbt).groups["Name"].value    

                }
            }
            else {
                $Hostname = $Null
            }
       
            #write a custom object to the pipeline              
            [pscustomobject]@{
                IPAddress  = $Target
                Hostname   = $Hostname
                Pinged     = $ping
                TTL        = $using:TTL
                Buffersize = $using:buffer
                Delay      = $Using:Delay
                TestDate   = Get-Date
            }
            
        }
    } #close scriptblock


    #hashtable of parameters for Invoke-Command
    $icmHash = @{
        Scriptblock      = $sb
        Computername     = $Computername
        HideComputername = $True
    }
    if ($AsJob) {
        Write-Verbose "Creating a background job"
        #Start-Job -ScriptBlock $sb -Name "Ping $subnet" 
        $icmHash.Add("AsJob", $True)
        $icmHash.Add("JobName", "Ping $subnet") 
    }
    Write-Verbose "Running the command"
    Invoke-Command @icmHash | Select-object -Property * -ExcludeProperty RunspaceID
 
} #end function


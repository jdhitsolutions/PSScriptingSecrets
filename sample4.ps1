
Return "This is a walkthrough demo"

#region using Write-Host
$net = "172.16.10.{0}"
100..120 | foreach {
    $ip = $net -f $_
    write-Host "Testing $IP" -ForegroundColor cyan
    Try {
        $test = Test-Connection -ComputerName $IP -Count 1 -ErrorAction Stop
        $IP
    }
    Catch {
        #ignore the error
    }
}

#endregion

#region Using Write-Progress
help Write-Progress -ShowWindow

#varies if you are in the ISE or a console

$network = "172.16.10.0"
$p = @{
Activity = "Subnet Sweep"
Status = "Testing network $network"
CurrentOperation = ""
PercentComplete = 0
}

$n = 100..120
$i=0
$n | foreach {
    $ip = $network -replace '0$',$_
    $i++
    $p.CurrentOperation = "pinging $ip"
    $p.PercentComplete = ($i/$n.count)*100
    Write-Progress @p
    Try {
        $test = Test-Connection -ComputerName $IP -Count 1 -ErrorAction Stop
        $IP
    }
    Catch {
        #ignore the error
    }
}


<#you rarely need this code
$p.CurrentOperation = "Finished"
$p.add("completed",$True)
Write-Progress @p
#>

psedit .\Test-Subnet.ps1
#run in the powerShell console
start powershell -ArgumentList "-noexit -noprofile -command &{. .\test-subnet.ps1; test-subnet -range (100..110)}"

#endregion
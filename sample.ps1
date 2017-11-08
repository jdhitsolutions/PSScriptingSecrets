#requires -version 5.1

#this is a sample script
Function Get-Foo {
    [cmdletbinding()]
    Param(
        [Parameter(Position=0,Mandatory,ValueFromPipeline)]
        [string]$Item
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        #this code runs once
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $Variable "
        Get-CimInstance -ClassName
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end 

} #close Get-Foo
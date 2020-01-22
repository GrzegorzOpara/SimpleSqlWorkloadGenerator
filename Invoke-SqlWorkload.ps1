    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$true,HelpMessage="The Sql Server instance name or azure server name")] 
        [string]$ServerInstance,
        [Parameter(Mandatory=$true,HelpMessage="The database name")]
        [string]$Database,
        [Parameter(Mandatory=$false,HelpMessage="The username if the connection is made using SQL Authentication")]
        [string]$UserName,
        [Parameter(Mandatory=$false,HelpMessage="The password for the username if the connection is made using SQL Authentication")]
        [string]$Pass,
        [Parameter(Mandatory=$false,HelpMessage="The duration of the execution in seconds. The default value: 60 seconds.")]
        [string]$Duration = 60,
        [Parameter(Mandatory=$false,HelpMessage="The maximum duration of idle time between queries execution. It's a random number between 0 and the parameter value. The default is 5 seconds.")]
        [string]$SleepTime = 5,
        [Parameter(Mandatory=$false,HelpMessage="The query separator used in the query file. The default value is --Query.")]
        [string]$QuerySeparator = '--Query',
        [Parameter(Mandatory=$true,HelpMessage="The file with queries separated by the Query Separator parameter.")]
        [string]$QueriesFile
    )

    # Set the internal variables
    $endTime = (Get-Date).AddSeconds($Duration)

    # Load the queries file into the array
    $queriesList = Get-Content -Delimiter $QuerySeparator -Path $QueriesFile

    # infinite loop to be finished by the duration check
    while(1 -eq 1) {
        # Checks if the duration has been reached
        $startTime = Get-Date
        if($startTime -gt $endTime) {
            Break;
        }
        
        # Generate random number (with the maximum as a number of elements in the queries list) and execute the query againt the server specified
        $rnd = Get-Random -Maximum $queriesList.Count
        Write-Host $queriesList[$rnd]

        Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Username $UserName -Password $Pass -Query $queriesList[$rnd] | out-null

        # Wait up to 1 second 
        Start-Sleep -Seconds (Get-Random -Maximum $SleepTime)
    }




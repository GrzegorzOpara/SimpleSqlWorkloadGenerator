# Simple Sql Workload Generator

The very simple powershell script to execute queries against a specified SQL server in order to generate the workload. It randomly picks up the query from the file and executes it on the specified database, then repeats that until specified time elapses.

## Getting Started

Download the Invoke-SqlWorkload.ps1 along with the SqlScripts folder. At this point there is only one sample file with queries (StackOverflow2010_queries.sql) in SqlScripts folder. The script is based on StackOverflow2010 databases (it can be dwonloaded from here: https://www.brentozar.com/archive/2018/01/updated-and-smaller-stack-overflow-demo-databases/).

### Prerequisites

**Powershell** and **SqlServer** modeule are required in order to make is work.

## Examples

### Example 1
Executes queries from **StackOverflow2010_queries.sql** file on **stackoverflow2010_highusage database** on **sqlserver-ii2ohj2n2pda4.database.windows.net server**. The queries execution takes **60 second**. The SQL authentication is being used.

_./Invoke-SqlWorkload -ServerInstance sqlserver-ii2ohj2n2pda4.database.windows.net -Database stackoverflow2010_highusage -UserName SqlServerAdmin -Pass Pa$$w0rd -QueriesFile .\SqlScripts\StackOverflow2010_queries.sql -Duration 60_

## Authors

* **Grzegorz Opara** - *Initial work* - (https://github.com/GrzegorzOpara)

## License

This project is licensed under the MIT License.


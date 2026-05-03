#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Retrieves the history of installed updates

.DESCRIPTION
    Queries the Windows Update Agent to retrieve a list of recently installed, failed, or pending updates. This script provides details on the update title, date, operation type, and result code.

.PARAMETER MaxEvents
    Specifies the maximum number of history entries to retrieve. Defaults to 50.

.PARAMETER ComputerName
    Specifies the name of the target computer. Defaults to the local computer.

.PARAMETER Credential
    Specifies a PSCredential object for remote connection.

.EXAMPLE
    PS> ./Get-UpdateHistory.ps1 -MaxEvents 20

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [int]$MaxEvents = 50,

    [string]$ComputerName = $env:COMPUTERNAME,

    [pscredential]$Credential
)

Process {
    try {
        $scriptBlock = {
            Param($Count)
            $objSession = New-Object -ComObject "Microsoft.Update.Session"
            $objSearcher = $objSession.CreateUpdateSearcher()
            $totalCount = $objSearcher.GetTotalHistoryCount()
            
            $history = $objSearcher.QueryHistory(0, [math]::Min($totalCount, $Count))
            
            $results = foreach ($entry in $history) {
                [PSCustomObject]@{
                    Title       = $entry.Title
                    Date        = $entry.Date
                    Operation   = switch ($entry.Operation) {
                        1 { "Installation" }
                        2 { "Uninstallation" }
                        3 { "Other" }
                        default { "Unknown" }
                    }
                    ResultCode  = switch ($entry.ResultCode) {
                        2 { "Success" }
                        3 { "SuccessWithErrors" }
                        4 { "Failed" }
                        5 { "Aborted" }
                        default { "Other ($($entry.ResultCode))" }
                    }
                    Description = $entry.Description
                    SupportUrl  = $entry.SupportUrl
                }
            }
            $results
        }

        if ($ComputerName -ne $env:COMPUTERNAME) {
            $invokeParams = @{
                'ComputerName' = $ComputerName
                'ScriptBlock'  = $scriptBlock
                'ArgumentList' = $MaxEvents
                'ErrorAction'  = 'Stop'
            }
            if ($null -ne $Credential) {
                $invokeParams.Add('Credential', $Credential)
            }

            $result = Invoke-Command @invokeParams
        }
        else {
            $result = &$scriptBlock -Count $MaxEvents
        }

        $results = foreach ($r in $result) {
            $r | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName -PassThru
        }

        Write-Output ($results | Sort-Object Date -Descending)
    }
    catch {
        throw
    }
}

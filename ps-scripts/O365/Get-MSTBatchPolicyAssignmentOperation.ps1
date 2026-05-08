#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Retrieve the status of batch policy assignment operations
.DESCRIPTION
    Retrieves the status of batch policy assignment operations. Supports optional filtering by OperationID and Status.
.PARAMETER OperationID
    The ID of the batch operation
.PARAMETER Status
    The status filter for the operation (NotStarted, InProgress, Completed)
.EXAMPLE
    PS> ./Get-MSTBatchPolicyAssignmentOperation.ps1
.EXAMPLE
    PS> ./Get-MSTBatchPolicyAssignmentOperation.ps1 -OperationID "op-id" -Status "Completed"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$OperationID,
    [ValidateSet('NotStarted', 'InProgress', 'Completed')]
    [string]$Status
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}
        if (-not [System.String]::IsNullOrWhiteSpace($OperationID)) {
            $getArgs.Add('OperationID', $OperationID)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($Status)) {
            $getArgs.Add('Status', $Status)
        }

        $result = Get-CsBatchPolicyAssignmentOperation @getArgs | Select-Object *

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No batch policy assignment operations found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}

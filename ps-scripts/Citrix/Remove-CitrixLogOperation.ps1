<#
.SYNOPSIS
	Citrix: Removes configuration log operations
.DESCRIPTION
	Deletes administrative operations from the configuration log history.
.PARAMETER OperationId
	The unique ID of the operation to remove.
.EXAMPLE
	PS> ./Remove-CitrixLogOperation.ps1 -OperationId 123
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[int]$OperationId
)

try {
	Import-Module Citrix.ConfigurationLogging.Admin.V1 -ErrorAction Stop
	Remove-LogOperation -Id $OperationId -ErrorAction Stop
	Write-Output "Successfully removed log operation '$OperationId'."
} catch {
	Write-Error $_
	exit 1
}
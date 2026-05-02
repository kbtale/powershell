<#
.SYNOPSIS
	Azure: Gets Azure consumption usage details
.DESCRIPTION
	Retrieves detailed consumption usage for the Azure subscription.
.PARAMETER BillingPeriodName
	The name of the billing period (optional).
.PARAMETER Top
	The maximum number of records to return (optional).
.EXAMPLE
	PS> ./Get-ConsumptionUsageDetail.ps1 -Top 100
.CATEGORY Azure
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$BillingPeriodName,

	[Parameter(Mandatory = $false)]
	[int]$Top
)

try {
	Import-Module Az.Consumption -ErrorAction Stop
	
	[hashtable]$cmdArgs = @{ 'ErrorAction' = 'Stop' }
	if ($BillingPeriodName) { $cmdArgs.Add('BillingPeriodName', $BillingPeriodName) }
	if ($Top) { $cmdArgs.Add('MaxCount', $Top) }

	$usage = Get-AzConsumptionUsageDetail @cmdArgs
	Write-Output $usage
} catch {
	Write-Error $_
	exit 1
}
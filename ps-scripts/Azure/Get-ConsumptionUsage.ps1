<#
.SYNOPSIS
	Azure: Gets Azure consumption usage details
.DESCRIPTION
	Retrieves detailed usage records for the current Azure subscription, with support for filtering by billing period, tags, and date range.
.PARAMETER BillingPeriodName
	Name of a specific billing period.
.PARAMETER IncludeMeterDetails
	Include meter details in the usage records.
.PARAMETER IncludeAdditionalProperties
	Include additional properties in the usage records.
.PARAMETER MaxCount
	Maximum number of records to return.
.PARAMETER Tag
	The tag of the usages to filter.
.PARAMETER StartDate
	The start date for filtering usage records.
.PARAMETER EndDate
	The end date for filtering usage records.
.PARAMETER InstanceName
	The specific instance name to filter.
.PARAMETER Properties
	List of properties to include in the output. Use * for all properties.
.EXAMPLE
	PS> ./Get-ConsumptionUsage.ps1 -MaxCount 10
.CATEGORY Azure
#>

param(
	[string]$BillingPeriodName,
	[switch]$IncludeMeterDetails,
	[switch]$IncludeAdditionalProperties,
	[int]$MaxCount,
	[string]$Tag,
	[datetime]$StartDate,
	[datetime]$EndDate,
	[string]$InstanceName,
	[ValidateSet('*', 'UsageStart', 'UsageEnd', 'BillingPeriodName', 'InstanceName')]
	[string[]]$Properties = @('UsageStart', 'UsageEnd', 'BillingPeriodName', 'InstanceName')
)

try {
	Import-Module Az.Billing -ErrorAction Stop

	if ($Properties -contains '*') {
		$Properties = @('*')
	}

	[hashtable]$cmdArgs = @{
		'ErrorAction'                 = 'Stop'
		'IncludeMeterDetails'         = $IncludeMeterDetails
		'IncludeAdditionalProperties' = $IncludeAdditionalProperties
	}

	if ($MaxCount -gt 0) {
		$cmdArgs.Add('MaxCount', $MaxCount)
	}
	if (-not [string]::IsNullOrWhiteSpace($BillingPeriodName)) {
		$cmdArgs.Add('BillingPeriodName', $BillingPeriodName)
	}
	if (-not [string]::IsNullOrWhiteSpace($InstanceName)) {
		$cmdArgs.Add('InstanceName', $InstanceName)
	}
	if (-not [string]::IsNullOrWhiteSpace($Tag)) {
		$cmdArgs.Add('Tag', $Tag)
	}
	if ($null -ne $StartDate -and $StartDate.Year -gt 2000) {
		$cmdArgs.Add('StartDate', $StartDate.ToUniversalTime())
	}
	if ($null -ne $EndDate -and $EndDate.Year -gt 2000) {
		$cmdArgs.Add('EndDate', $EndDate.ToUniversalTime())
	}

	$ret = Get-AzConsumptionUsageDetail @cmdArgs | Sort-Object UsageStart -Descending | Select-Object $Properties
	Write-Output $ret
} catch {
	Write-Error $_
	exit 1
}

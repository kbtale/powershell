<#
.SYNOPSIS
	Citrix: Creates a new application
.DESCRIPTION
	Creates a new application resource in the Citrix site.
.PARAMETER Name
	The display name of the application.
.PARAMETER CommandLineExecutable
	The full path to the executable file.
.EXAMPLE
	PS> ./New-CitrixApplication.ps1 -Name "Calc" -CommandLineExecutable "C:\Windows\System32\calc.exe"
.CATEGORY Citrix
#>
param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$CommandLineExecutable
)

try {
	Import-Module Citrix.Broker.Admin.V2 -ErrorAction Stop
	$app = New-BrokerApplication -Name $Name -CommandLineExecutable $CommandLineExecutable -ErrorAction Stop
	Write-Output $app
} catch {
	Write-Error $_
	exit 1
}
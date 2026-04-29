<#
.SYNOPSIS
	Opens the default email client to write a new email
.DESCRIPTION
	This PowerShell script opens the default email client to write a new email.
.PARAMETER EmailAddress
	Specifies the email address fill in
.EXAMPLE
	PS> ./new-email.ps1
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
.CATEGORY New
#>

param([string]$EmailAddress = "markus@fleschutz.de", [string]$Url = "mailto:$EmailAddress")

try {
	Start-Process $URL
	exit 0 # success
} catch {
	"?? ERROR: $($Error[0]) (script line $($_.InvocationInfo.ScriptLineNumber))"
	exit 1
}
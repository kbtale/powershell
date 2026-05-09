<#
.SYNOPSIS
	Starts the default email client
.DESCRIPTION
	This PowerShell script launches the default email client.
.EXAMPLE
	PS> ./open-email-client
.CATEGORY Navigation
#>

#requires -version 5.1

try {
	start-process "mailto:markus@fleschutz.de"
	exit 0
} catch {
throw
}

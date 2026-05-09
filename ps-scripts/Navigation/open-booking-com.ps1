<#
.SYNOPSIS
	Opens the Booking.com website
.DESCRIPTION
	This PowerShell script launches the Web browser with the Booking.com website.
.EXAMPLE
	PS> ./open-booking-com
.CATEGORY Navigation
#>

#requires -version 5.1

& "$PSScriptRoot/open-default-browser.ps1" "https://www.booking.com"
exit 0

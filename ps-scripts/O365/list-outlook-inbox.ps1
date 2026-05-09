<#
.SYNOPSIS
	Lists Outlook's Inbox
.DESCRIPTION
	This PowerShell script lists the emails in the inbox of Outlook.
.EXAMPLE
	PS> ./list-outlook-inbox.ps1
.CATEGORY O365
#>

#Requires -Version 5.1

try {
	$Outlook = New-Object -com Outlook.application
	$MAPI = $Outlook.GetNameSpace("MAPI")
	$Inbox = $MAPI.GetDefaultFolder(6)
	$Inbox.items | Select Received,Subject | Format-Table -AutoSize
	exit 0
} catch {
throw
}

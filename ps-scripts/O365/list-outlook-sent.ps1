<#
.SYNOPSIS
	Lists Outlook's Sent Mails
.DESCRIPTION
	This PowerShell script lists the mails in the Sent Mail folder of Outlook.
.EXAMPLE
	PS> ./list-outlook-sent.ps1
.CATEGORY O365
#>

#Requires -Version 5.1

try {
	$Outlook = New-Object -com Outlook.application
	$MAPI = $Outlook.GetNameSpace("MAPI")
	$Inbox = $MAPI.GetDefaultFolder(5)
	$Inbox.items | Select SentOn,Subject | Format-Table -AutoSize
	exit 0
} catch {
throw
}

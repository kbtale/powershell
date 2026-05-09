<#
.SYNOPSIS
	Lists the content of the recycle bin folder
.DESCRIPTION
	This PowerShell script lists the content of the recycle bin folder.
.EXAMPLE
	PS> ./list-recycle-bin.ps1
.CATEGORY System
#>

#Requires -Version 5.1

try {
	(New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() | Select-Object Name,Size,Path
	exit 0
} catch {
throw
}

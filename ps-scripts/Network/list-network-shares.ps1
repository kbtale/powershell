<#
.SYNOPSIS
	List network shares
.DESCRIPTION
	This PowerShell script lists all network shares (aka "shared folders") of the local computer.
.EXAMPLE
	PS> ./list-network-shares.ps1
		✅ Folder D:\Public shared as: \\LAPTOP\Public ('File transfer folder')
.CATEGORY Network
#>

#Requires -Version 5.1

try {
	if ($IsLinux -or $IsMacOS) {
		# TODO
	} else {
		$shares = Get-WmiObject win32_share | where {$_.name -NotLike "*$"} 
		foreach ($share in $shares) {
			if ($share.Description -eq "") {
				Write-Host "✅ Folder $($share.Path) shared as: \\$(hostname)\$($share.Name)"
			} else {
				Write-Host "✅ Folder $($share.Path) shared as: \\$(hostname)\$($share.Name) ('$($share.Description)')"
			}
		}
	}
	exit 0
} catch {
throw
}

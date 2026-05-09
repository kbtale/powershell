<#
.SYNOPSIS
	Lists the installed languages
.DESCRIPTION
	This PowerShell script lists the installed languages.
.EXAMPLE
	PS> ./list-installed-languages.ps1
		Tag   Autonym               English Spellchecking Handwriting
		---   -------               ------- ------------- -----------
		de-DE Deutsch (Deutschland) German  True          False
.CATEGORY System
#>

#Requires -Version 5.1

function ListInstalledLanguages { 
	$List = Get-WinUserLanguageList
	foreach ($Item in $List) {
		New-Object PSObject -Property @{ Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss"); 'Tag' = "$($Item.LanguageTag)"; 'Autonym' = "$($Item.Autonym)"; 'English' = "$($Item.EnglishName)"; 'Spellchecking' = "$($Item.Spellchecking)"; 'Handwriting' = "$($Item.Handwriting)" }
	}
}

try {
	ListInstalledLanguages | Format-Table -property Tag,Autonym,English,Spellchecking,Handwriting
	exit 0
} catch {
throw
}

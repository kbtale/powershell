<#
.SYNOPSIS
    Md2docx
.CATEGORY Convert
#>



gci -r -i *.md |foreach{$docx=$_.directoryname+"\"+$_.basename+".docx";pandoc -f markdown -s --citeproc $_.name -o $docx}

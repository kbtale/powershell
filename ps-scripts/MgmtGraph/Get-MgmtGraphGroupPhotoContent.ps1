#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Downloads a group profile photo to a file

.DESCRIPTION
    Downloads the binary content of a specified group's profile photo and saves it to the specified local file path.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER OutFile
    The local file path where the group photo should be saved.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupPhotoContent.ps1 -GroupId "group-id-123" -OutFile "C:\temp\group.jpg"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$OutFile
)

Process {
    try {
        Get-MgGroupPhotoContent -GroupId $GroupId -OutFile $OutFile -ErrorAction Stop
        
        $fileInfo = Get-Item -Path $OutFile -ErrorAction SilentlyContinue
        
        $result = [PSCustomObject]@{
            GroupId     = $GroupId
            FilePath    = $OutFile
            SizeInBytes = if ($fileInfo) { $fileInfo.Length } else { $null }
            Downloaded  = [bool]$fileInfo
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}

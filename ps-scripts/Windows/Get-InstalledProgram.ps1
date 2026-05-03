#Requires -Version 5.1

<#
.SYNOPSIS
    Windows: Lists installed software and programs

.DESCRIPTION
    Retrieves a list of installed software from the local or remote computer. This script primarily queries the Windows Registry (Uninstall keys) for performance and reliability, providing a comprehensive inventory including version and publisher details.

.PARAMETER ComputerName
    Specifies the name of the computer to query. Defaults to the local computer.

.PARAMETER Name
    Specifies a filter for the program name (supports wildcards).

.PARAMETER IncludeSystemUpdates
    If set, includes Windows Updates and system components in the list.

.EXAMPLE
    PS> ./Get-InstalledProgram.ps1 -Name "*Office*"

.CATEGORY Windows
#>

[CmdletBinding()]
Param
(
    [string]$ComputerName = $env:COMPUTERNAME,

    [string]$Name,

    [switch]$IncludeSystemUpdates
)

Process
{
    try
    {
        $scriptBlock = {
            Param($FilterName, $IncludeUpdates)

            $registryPaths = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )

            $results = foreach ($path in $registryPaths)
            {
                Get-ItemProperty $path -ErrorAction SilentlyContinue | ForEach-Object {
                    if (-not [string]::IsNullOrWhiteSpace($_.DisplayName))
                    {
                        if (-not $IncludeUpdates -and ($_.ReleaseType -eq "Security Update" -or $_.ReleaseType -eq "Update" -or $_.DisplayName -match "KB\d{6,7}"))
                        {
                            return
                        }

                        [PSCustomObject]@{
                            Name            = $_.DisplayName
                            Version         = $_.DisplayVersion
                            Publisher       = $_.Publisher
                            InstallDate     = $_.InstallDate
                            UninstallString = $_.UninstallString
                            Source          = $_.InstallSource
                        }
                    }
                }
            }

            if (-not [string]::IsNullOrWhiteSpace($FilterName))
            {
                $results = $results | Where-Object { $_.Name -like $FilterName }
            }

            return $results | Sort-Object Name
        }

        if ($ComputerName -ne $env:COMPUTERNAME)
        {
            $result = Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock -ArgumentList $Name, $IncludeSystemUpdates
        }
        else
        {
            $result = &$scriptBlock -FilterName $Name -IncludeUpdates $IncludeSystemUpdates
        }

        Write-Output $result
    }
    catch
    {
        throw
    }
}

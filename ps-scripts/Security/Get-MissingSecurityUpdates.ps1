#Requires -Version 5.1

<#
.SYNOPSIS
    Security: Queries outstanding critical security updates and hotfixes
.DESCRIPTION
    Queries the local Windows Update Agent (COM) for missing updates, filtering for Critical and Security patches, or optionally returning all outstanding updates.
.PARAMETER IncludeOptional
    Include optional software updates, driver updates, and feature packs (by default, audits only Critical and Security updates)
.EXAMPLE
    PS> ./Get-MissingSecurityUpdates.ps1
.CATEGORY Security
#>

[CmdletBinding()]
Param(
    [switch]$IncludeOptional
)

Process {
    try {
        Write-Verbose "Initializing Windows Update Client COM session..."
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $updateSearcher.ServerSelection = 3 # Search all standard channels

        Write-Verbose "Searching for missing updates (this may take a minute)..."
        # Search criteria: IsInstalled=0 means uninstalled, Type='Software' filters out driver files
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software'")
        
        if ($null -eq $searchResult -or $searchResult.Updates.Count -eq 0) {
            Write-Host "All software updates are up-to-date! No missing patches." -ForegroundColor Green
            return
        }

        $results = @()
        foreach ($update in $searchResult.Updates) {
            # Check categories
            $categoriesList = @()
            $isCriticalOrSecurity = $false
            foreach ($cat in $update.Categories) {
                $categoriesList += $cat.Name
                if ($cat.Name -eq 'Security Updates' -or $cat.Name -eq 'Critical Updates') {
                    $isCriticalOrSecurity = $true
                }
            }

            if ($isCriticalOrSecurity -or $IncludeOptional) {
                # Extract KB article number(s)
                $kbArticles = @()
                if ($update.KBArticleIDs) {
                    foreach ($id in $update.KBArticleIDs) {
                        $kbArticles += "KB$id"
                    }
                }
                $kbString = if ($kbArticles.Count -gt 0) { $kbArticles -join ', ' } else { 'N/A' }

                $results += [PSCustomObject]@{
                    Title          = $update.Title
                    KBArticle      = $kbString
                    Severity       = if ($update.MsrcSeverity) { $update.MsrcSeverity } else { 'Important' }
                    Categories     = ($categoriesList -join ', ')
                    IsDownloaded   = $update.IsDownloaded
                    IsMandatory    = $update.IsMandatory
                    SizeEstimateMB = [Math]::Round($update.MaxDownloadSize / 1MB, 2)
                }
            }
        }

        if ($results.Count -eq 0) {
            Write-Host "No missing Security or Critical updates found. System is secure!" -ForegroundColor Green
        } else {
            Write-Warning "Outstanding missing security/critical updates detected!"
            Write-Output ($results | Sort-Object Severity -Descending)
        }
    }
    catch {
        Write-Error $_
        throw
    }
}

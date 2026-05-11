#Requires -Version 5.1

<#
.SYNOPSIS
    AWS: Audits EC2 instances across specified regions for status and security tags
.DESCRIPTION
    Scans Amazon EC2 instances across a selection of target AWS regions, returning active states, network configurations, and checking compliance against baseline tracking tags (such as Environment or Owner).
.PARAMETER Regions
    An array of AWS region strings to scan. Defaults to 'us-east-1' and 'us-west-2'.
.PARAMETER RequiredTags
    Baseline tracking tags that must exist on all EC2 instances. Defaults to 'Environment' and 'Owner'.
.EXAMPLE
    PS> ./Get-AWSInstanceAudit.ps1 -Regions "us-east-1", "eu-west-1" -RequiredTags "Environment", "CostCenter"
.CATEGORY AWS
#>

[CmdletBinding()]
Param(
    [string[]]$Regions = @('us-east-1', 'us-west-2'),

    [string[]]$RequiredTags = @('Environment', 'Owner')
)

Process {
    try {
        $awsToolsCommon = Get-Module -ListAvailable -Name AWS.Tools.Common
        $awsToolsEC2    = Get-Module -ListAvailable -Name AWS.Tools.EC2
        $awsPowerShell  = Get-Module -ListAvailable -Name AWSPowerShell

        if (-not ($awsToolsCommon -and $awsToolsEC2) -and -not $awsPowerShell) {
            Write-Warning "Required AWS Tools for PowerShell modules are not installed."
            Write-Host "Please install AWS.Tools by running the following commands in an Administrative PowerShell session:" -ForegroundColor Yellow
            Write-Host "  Install-Module -Name AWS.Tools.Common -Force" -ForegroundColor Cyan
            Write-Host "  Install-Module -Name AWS.Tools.EC2 -Force" -ForegroundColor Cyan
            Write-Host "Alternatively, install the unified AWSPowerShell module:" -ForegroundColor Yellow
            Write-Host "  Install-Module -Name AWSPowerShell -Force" -ForegroundColor Cyan
            return
        }

        if ($awsToolsEC2) {
            Import-Module AWS.Tools.EC2 -ErrorAction Stop
        } elseif ($awsPowerShell) {
            Import-Module AWSPowerShell -ErrorAction Stop
        }

        $results = @()

        foreach ($region in $Regions) {
            Write-Verbose "Auditing AWS EC2 instances in region '$region'..."
            try {
                $reservations = Get-EC2Instance -Region $region -ErrorAction Stop
                
                foreach ($res in $reservations) {
                    foreach ($inst in $res.Instances) {
                        $nameTag = $inst.Tags | Where-Object { $_.Key -eq 'Name' }
                        $instanceName = if ($nameTag) { $nameTag.Value } else { 'Unnamed Instance' }

                        $missingTags = @()
                        foreach ($reqTag in $RequiredTags) {
                            $tagMatch = $inst.Tags | Where-Object { $_.Key -eq $reqTag }
                            if (-not $tagMatch -or [string]::IsNullOrWhiteSpace($tagMatch.Value)) {
                                $missingTags += $reqTag
                            }
                        }

                        $isCompliant = ($missingTags.Count -eq 0)
                        $status = if ($isCompliant) { "Compliant" } else { "NON-COMPLIANT (Missing: $($missingTags -join ', '))" }

                        $results += [PSCustomObject]@{
                            Region       = $region
                            InstanceID   = $inst.InstanceId
                            Name         = $instanceName
                            State        = $inst.State.Name
                            InstanceType = $inst.InstanceType
                            PublicIP     = if ($inst.PublicIpAddress) { $inst.PublicIpAddress } else { 'None (Private)' }
                            PrivateIP    = $inst.PrivateIpAddress
                            Compliance   = $status
                            IsCompliant  = $isCompliant
                        }
                    }
                }
            }
            catch {
                Write-Warning "Failed to query EC2 instances in region '$region': $_"
            }
        }

        if ($results.Count -eq 0) {
            Write-Host "No Amazon EC2 instances located across audited regions." -ForegroundColor Yellow
            return
        }

        Write-Output ($results | Sort-Object IsCompliant, Region)
    }
    catch {
        Write-Error $_
        throw
    }
}

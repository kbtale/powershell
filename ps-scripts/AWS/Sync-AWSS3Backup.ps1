#Requires -Version 5.1

<#
.SYNOPSIS
    AWS: Syncs a local folder to an Amazon S3 Bucket
.DESCRIPTION
    Performs directory synchronization to an AWS S3 Bucket. Compares local file MD5 hashes against S3 ETags to skip unchanged files, uploads modified/new files, and optionally purges deleted files in S3.
.PARAMETER LocalFolderPath
    The local folder on the host machine to synchronize.
.PARAMETER BucketName
    The name of the destination Amazon S3 bucket.
.PARAMETER Purge
    If toggled, deletes files in S3 that no longer exist in the local folder.
.EXAMPLE
    PS> ./Sync-AWSS3Backup.ps1 -LocalFolderPath "C:\Data" -BucketName "my-corporate-backups" -Purge
.CATEGORY AWS
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LocalFolderPath,

    [Parameter(Mandatory = $true)]
    [string]$BucketName,

    [switch]$Purge
)

Process {
    try {
        $awsToolsCommon = Get-Module -ListAvailable -Name AWS.Tools.Common
        $awsToolsS3     = Get-Module -ListAvailable -Name AWS.Tools.S3
        $awsPowerShell  = Get-Module -ListAvailable -Name AWSPowerShell

        if (-not ($awsToolsCommon -and $awsToolsS3) -and -not $awsPowerShell) {
            Write-Warning "Required AWS Tools for S3 modules are not installed."
            Write-Host "Please install AWS.Tools by running the following commands in an Administrative PowerShell session:" -ForegroundColor Yellow
            Write-Host "  Install-Module -Name AWS.Tools.Common -Force" -ForegroundColor Cyan
            Write-Host "  Install-Module -Name AWS.Tools.S3 -Force" -ForegroundColor Cyan
            return
        }

        if ($awsToolsS3) {
            Import-Module AWS.Tools.S3 -ErrorAction Stop
        } elseif ($awsPowerShell) {
            Import-Module AWSPowerShell -ErrorAction Stop
        }

        $absolutePath = [System.IO.Path]::GetFullPath($LocalFolderPath)
        if (-not (Test-Path -Path $absolutePath -PathType Container)) {
            throw "Local folder path '$LocalFolderPath' does not exist or is not a directory."
        }

        Write-Verbose "Verifying accessibility of S3 bucket '$BucketName'..."
        $bucketCheck = Get-S3Bucket -BucketName $BucketName -ErrorAction SilentlyContinue
        if (-not $bucketCheck) {
            throw "S3 Bucket '$BucketName' was not found or is inaccessible under current credentials."
        }

        $localFiles = Get-ChildItem -Path $absolutePath -File -Recurse

        Write-Verbose "Fetching existing objects in S3 bucket..."
        $s3Objects = Get-S3Object -BucketName $BucketName -ErrorAction SilentlyContinue
        if ($null -eq $s3Objects) { $s3Objects = @() }

        $uploadedCount = 0
        $skippedCount  = 0
        $deletedCount  = 0

        $localKeysMap = @{}

        foreach ($file in $localFiles) {
            $relativeKey = $file.FullName.Substring($absolutePath.Length).TrimStart('\').Replace('\', '/')
            $localKeysMap.Add($relativeKey, $file.FullName)

            $s3Obj = $s3Objects | Where-Object { $_.Key -eq $relativeKey }

            $needsUpload = $false
            if (-not $s3Obj) {
                $needsUpload = $true
                Write-Verbose "File '$relativeKey' does not exist in S3. Scheduling upload..."
            } else {
                $localMd5 = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash.ToLower()
                $s3Etag   = $s3Obj.ETag.Trim('"').ToLower()

                if ($localMd5 -ne $s3Etag) {
                    $needsUpload = $true
                    Write-Verbose "File '$relativeKey' has changed (MD5 mismatch). Scheduling upload..."
                }
            }

            if ($needsUpload) {
                Write-Host "Uploading '$relativeKey' to bucket '$BucketName'..." -ForegroundColor Cyan
                Write-S3Object -BucketName $BucketName -File $file.FullName -Key $relativeKey -ErrorAction Stop | Out-Null
                $uploadedCount++
            } else {
                $skippedCount++
            }
        }

        if ($Purge) {
            foreach ($s3Obj in $s3Objects) {
                if (-not $localKeysMap.ContainsKey($s3Obj.Key)) {
                    Write-Host "Purging orphaned object '$($s3Obj.Key)' from bucket '$BucketName'..." -ForegroundColor Yellow
                    Remove-S3Object -BucketName $BucketName -Key $s3Obj.Key -Force -ErrorAction Stop | Out-Null
                    $deletedCount++
                }
            }
        }

        Write-Host "`nSynchronization complete!" -ForegroundColor Green
        [PSCustomObject]@{
            SourceDirectory = $absolutePath
            TargetS3Bucket  = $BucketName
            UploadedFiles   = $uploadedCount
            SkippedFiles    = $skippedCount
            PurgedS3Objects = $deletedCount
        }
    }
    catch {
        Write-Error $_
        throw
    }
}

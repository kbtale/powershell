#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Creates a new resource mailbox
.DESCRIPTION
    Creates a new room resource mailbox in Exchange Online. Only parameters with values are applied beyond the initial creation.
.PARAMETER Name
    Unique name of the resource, maximum 64 characters
.PARAMETER AccountDisabled
    Disable the account associated with the resource
.PARAMETER Alias
    Alias name of the resource
.PARAMETER DisplayName
    Display name of the resource
.PARAMETER ResourceCapacity
    Capacity of the resource
.PARAMETER WindowsEmailAddress
    Windows email address of the resource
.EXAMPLE
    PS> ./New-Resource.ps1 -Name "ConfRoom1" -DisplayName "Conference Room 1" -ResourceCapacity 10
.EXAMPLE
    PS> ./New-Resource.ps1 -Name "BoardRoom" -Alias "board" -WindowsEmailAddress "board@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [switch]$AccountDisabled,
    [string]$Alias,
    [string]$DisplayName,
    [int]$ResourceCapacity,
    [string]$WindowsEmailAddress
)

Process {
    try {
        [string[]]$Properties = @('AccountDisabled','Alias','DisplayName','ResourceCapacity','WindowsEmailAddress')

        $box = New-Mailbox -Name $Name -Room -Force -ErrorAction Stop

        if (-not [System.String]::IsNullOrWhiteSpace($Alias)) {
            $null = Set-Mailbox -Identity $Name -Alias $Alias -ErrorAction Stop
        }
        if (-not [System.String]::IsNullOrWhiteSpace($DisplayName)) {
            $null = Set-Mailbox -Identity $Name -DisplayName $DisplayName -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('ResourceCapacity')) {
            $null = Set-Mailbox -Identity $Name -ResourceCapacity $ResourceCapacity -ErrorAction Stop
        }
        if (-not [System.String]::IsNullOrWhiteSpace($WindowsEmailAddress)) {
            $null = Set-Mailbox -Identity $Name -WindowsEmailAddress $WindowsEmailAddress -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('AccountDisabled')) {
            $null = Set-Mailbox -Identity $Name -AccountDisabled $true -Confirm:$false -ErrorAction Stop
        }

        $result = Get-Mailbox -Identity $box.UserPrincipalName -ErrorAction Stop | Select-Object $Properties
        $result | ForEach-Object {
            $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}

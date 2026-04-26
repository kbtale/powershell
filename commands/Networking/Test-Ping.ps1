<#
.SYNOPSIS
    Pings a host multiple times.
.DESCRIPTION
    Sends ICMP echo requests to a specified host to check connectivity.
.PARAMETER Hostname
    The IP or DNS name of the host to ping.
.PARAMETER Count
    Number of pings to send.
.EXAMPLE
    Test-Ping -Hostname "google.com" -Count 4
.CATEGORY
    Networking
#>
param(
    [string]$Hostname = "google.com",
    [int]$Count = 4
)

Test-Connection -ComputerName $Hostname -Count $Count

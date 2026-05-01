<#
.SYNOPSIS
	Azure: Creates a new Azure virtual machine
.DESCRIPTION
	Deploys a new virtual machine to Azure with specified name, credentials, and configuration (size, image, network).
.PARAMETER Name
	The name of the new virtual machine.
.PARAMETER AdminCredential
	The administrator credentials for the VM.
.PARAMETER ResourceGroupName
	The name of the resource group to contain the VM.
.PARAMETER Location
	The Azure location for the VM.
.PARAMETER Image
	The OS image to use for the VM.
.PARAMETER Size
	The size of the virtual machine (e.g., Standard_DS1_v2).
.PARAMETER VirtualNetworkName
	The name of the virtual network.
.PARAMETER SubnetName
	The name of the subnet.
.PARAMETER SecurityGroupName
	The name of the network security group.
.PARAMETER AllocationMethod
	IP allocation method for the public IP (Static or Dynamic).
.PARAMETER DataDiskSizeInGb
	Size of data disks in GB.
.PARAMETER EnableUltraSSD
	Whether to enable UltraSSD disks.
.EXAMPLE
	PS> ./New-VM.ps1 -Name "myVM" -AdminCredential (Get-Credential) -ResourceGroupName "myRG"
.CATEGORY Azure
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[pscredential]$AdminCredential,

	[string]$ResourceGroupName,

	[string]$Location,

	[ValidateSet('Win2022AzureEditionCore', 'Win2019Datacenter', 'Win2016Datacenter', 'Win2012R2Datacenter', 'Win2012Datacenter', 'UbuntuLTS', 'CentOS', 'CoreOS', 'Debian', 'openSUSE-Leap', 'RHEL', 'SLES')]
	[string]$Image = "Win2019Datacenter",

	[string]$Size = 'Standard_DS1_v2',

	[string]$VirtualNetworkName,

	[string]$SubnetName,

	[string]$SecurityGroupName,

	[ValidateSet('Static', 'Dynamic')]
	[string]$AllocationMethod,

	[int]$DataDiskSizeInGb,

	[switch]$EnableUltraSSD
)

try {
	Import-Module Az.Compute -ErrorAction Stop

	[string[]]$Properties = @('Name', 'StatusCode', 'ResourceGroupName', 'Id', 'VmId', 'Location', 'ProvisioningState')

	[hashtable]$cmdArgs = @{
		'ErrorAction'    = 'Stop'
		'Confirm'        = $false
		'Credential'     = $AdminCredential
		'Name'           = $Name
		'Image'          = $Image
		'EnableUltraSSD' = $EnableUltraSSD
		'Size'           = $Size
	}

	if (-not [string]::IsNullOrWhiteSpace($ResourceGroupName)) { $cmdArgs.Add('ResourceGroupName', $ResourceGroupName) }
	if (-not [string]::IsNullOrWhiteSpace($Location)) { $cmdArgs.Add('Location', $Location) }
	if (-not [string]::IsNullOrWhiteSpace($SecurityGroupName)) { $cmdArgs.Add('SecurityGroupName', $SecurityGroupName) }
	if (-not [string]::IsNullOrWhiteSpace($SubnetName)) { $cmdArgs.Add('SubnetName', $SubnetName) }
	if (-not [string]::IsNullOrWhiteSpace($VirtualNetworkName)) { $cmdArgs.Add('VirtualNetworkName', $VirtualNetworkName) }
	if (-not [string]::IsNullOrWhiteSpace($AllocationMethod)) { $cmdArgs.Add('AllocationMethod', $AllocationMethod) }
	if ($DataDiskSizeInGb -gt 0) { $cmdArgs.Add('DataDiskSizeInGb', $DataDiskSizeInGb) }

	$ret = New-AzVM @cmdArgs | Select-Object $Properties
	Write-Output $ret
} catch {
	Write-Error $_
	exit 1
}

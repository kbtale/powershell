<#
.SYNOPSIS
	Azure: Removes an Azure virtual machine and optionally its associated resources
.DESCRIPTION
	Deletes a specified virtual machine from Azure. If -RemoveAssociatedResources is used, it attempts to clean up NICs, Managed Disks, Public IPs, and NSGs associated with the VM.
.PARAMETER Name
	The name of the virtual machine to remove.
.PARAMETER ResourceGroupName
	The name of the resource group containing the virtual machine.
.PARAMETER RemoveAssociatedResources
	If specified, attempts to remove associated resources (NICs, Disks, NSGs, Public IPs).
.EXAMPLE
	PS> ./Remove-VM.ps1 -Name "myVM" -ResourceGroupName "myRG" -RemoveAssociatedResources
.CATEGORY Azure
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$ResourceGroupName,

	[switch]$RemoveAssociatedResources
)

try {
	Import-Module Az.Compute -ErrorAction Stop
	if ($RemoveAssociatedResources) {
		Import-Module Az.Network -ErrorAction Stop
		Import-Module Az.Storage -ErrorAction Stop
	}

	$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction Stop
	$disks = Get-AzDisk | Where-Object { $_.ManagedBy -eq $vm.Id }

	if ($RemoveAssociatedResources) {
		# Handle pre-deletion cleanup (e.g., Boot Diagnostics container)
		if ($null -ne $vm.DiagnosticsProfile.bootDiagnostics) {
			try {
				Write-Output "Removing boot diagnostics container..."
				[string]$stoName = [regex]::match($vm.DiagnosticsProfile.bootDiagnostics.storageUri, '^http[s]?://(.+?)\.').groups[1].value
				$stoAcc = Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $stoName }
				if ($null -ne $stoAcc) {
					[string]$conName = ('bootdiagnostics-{0}-{1}' -f $vm.Name.ToLower().Substring(0, [Math]::Min($vm.Name.Length, 9)), $vm.vmId)
					$stoAcc | Get-AzStorageContainer | Where-Object { $_.Name -eq $conName } | Remove-AzStorageContainer -Force -ErrorAction SilentlyContinue
				}
			} catch {
				Write-Warning "Failed to remove boot diagnostics: $($_.Exception.Message)"
			}
		}
	}

	Write-Output "Removing virtual machine '$Name'..."
	Remove-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -Force -Confirm:$false -ErrorAction Stop

	if ($RemoveAssociatedResources) {
		Write-Output "Cleaning up associated resources..."
		
		# Remove NICs and Public IPs
		foreach ($nicID in $vm.NetworkProfile.NetworkInterfaces.Id) {
			try {
				$nicName = $nicID.Split('/')[-1]
				$nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nicName -ErrorAction SilentlyContinue
				if ($null -ne $nic) {
					Write-Output "Removing NIC '$nicName'..."
					Remove-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nicName -Force -Confirm:$false
					
					foreach ($ipConfig in $nic.IpConfigurations) {
						if ($null -ne $ipConfig.PublicIpAddress) {
							$pipName = $ipConfig.PublicIpAddress.Id.Split('/')[-1]
							Write-Output "Removing Public IP '$pipName'..."
							Remove-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $pipName -Force -Confirm:$false -ErrorAction SilentlyContinue
						}
					}
				}
			} catch {
				Write-Warning "Failed to remove network resources for NIC '$nicID': $($_.Exception.Message)"
			}
		}

		# Remove Managed Disks
		if ($null -ne $disks) {
			foreach ($disk in $disks) {
				Write-Output "Removing disk '$($disk.Name)'..."
				$disk | Remove-AzDisk -Force -Confirm:$false -ErrorAction SilentlyContinue
			}
		}

		# Remove NSG if it follows naming convention [VMName]*
		$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName | Where-Object { $_.Name -like "$Name*" }
		if ($null -ne $nsg) {
			Write-Output "Removing NSG '$($nsg.Name)'..."
			Remove-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $nsg.Name -Force -Confirm:$false -ErrorAction SilentlyContinue
		}
	}

	Write-Output "Virtual machine '$Name' removed successfully."
} catch {
	Write-Error $_
	exit 1
}

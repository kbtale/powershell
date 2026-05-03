<#
.SYNOPSIS
	Azure: Adds a certificate to an Azure Key Vault
.DESCRIPTION
	Generates a new certificate policy and adds a certificate to the specified Key Vault. Supports configuring issuer, subject, key type, and validity.
.PARAMETER VaultName
	The name of the Key Vault.
.PARAMETER Name
	The name for the new certificate.
.PARAMETER IssuerName
	The name of the certificate issuer (e.g., Self, or a CA name).
.PARAMETER SubjectName
	The subject name for the certificate.
.PARAMETER ContentType
	The content type of the secret (PKCS12 or PEM).
.PARAMETER CurveName
	Elliptic curve name for EC keys.
.PARAMETER KeyNotExportable
	If specified, the private key will be marked as not exportable.
.PARAMETER KeyType
	The type of key (RSA, EC, etc.).
.PARAMETER KeySize
	The size of the key in bits.
.PARAMETER ValidityInMonths
	How long the certificate is valid in months.
.EXAMPLE
	PS> ./Add-KeyVaultCertificate.ps1 -VaultName "myVault" -Name "myCert" -IssuerName "Self" -SubjectName "CN=myCert"
.CATEGORY Azure
#>

param(
	[Parameter(Mandatory = $true)]
	[string]$VaultName,

	[Parameter(Mandatory = $true)]
	[string]$Name,

	[Parameter(Mandatory = $true)]
	[string]$IssuerName,

	[Parameter(Mandatory = $true)]
	[string]$SubjectName,

	[ValidateSet('application/x-pkcs12', 'application/x-pem-file')]
	[string]$ContentType = 'application/x-pkcs12',

	[ValidateSet('P-256', 'P-384', 'P-521', 'P-256K', 'SECP256K1')]
	[string]$CurveName,

	[switch]$KeyNotExportable,

	[ValidateSet('RSA', 'RSA-HSM', 'EC', 'EC-HSM')]
	[string]$KeyType,

	[ValidateSet('256', '384', '521', '2048', '3072', '4096')]
	[string]$KeySize,

	[int]$ValidityInMonths = 6
)

try {
	Import-Module Az.KeyVault -ErrorAction Stop

	[hashtable]$policyArgs = @{
		'ErrorAction'       = 'Stop'
		'IssuerName'        = $IssuerName
		'SubjectName'       = $SubjectName
		'SecretContentType' = $ContentType
		'ValidityInMonths'  = $ValidityInMonths
		'Confirm'           = $false
	}

	if ($PSBoundParameters.ContainsKey('CurveName')) { $policyArgs.Add('Curve', $CurveName) }
	if ($PSBoundParameters.ContainsKey('KeySize')) { $policyArgs.Add('KeySize', $KeySize) }
	if ($PSBoundParameters.ContainsKey('KeyType')) { $policyArgs.Add('KeyType', $KeyType) }
	if ($KeyNotExportable) { $policyArgs.Add('KeyNotExportable', $true) }

	Write-Output "Generating certificate policy..."
	$cerPolicy = New-AzKeyVaultCertificatePolicy @policyArgs

	Write-Output "Adding certificate '$Name' to vault '$VaultName'..."
	$ret = Add-AzKeyVaultCertificate -VaultName $VaultName -Name $Name -CertificatePolicy $cerPolicy -Confirm:$false -ErrorAction Stop

	Write-Output $ret
} catch {
	Write-Error $_
	exit 1
}

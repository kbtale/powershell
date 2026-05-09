<#
.SYNOPSIS
	Lists the exchange rates for a currency
.DESCRIPTION
	This PowerShell script lists the current exchange rates for the given currency (USD per default).
.PARAMETER currency
	Specifies the base currency
.EXAMPLE
	PS> ./list-exchange-rates.ps1 EUR
		Current Exchange Rates for 1 EUR (source: http://www.floatrates.com)
		================================
		Rate           Currency                        Inverse    Date
		----           --------                        -------    ----
		1.09489154     USD - U.S. Dollar               0.91333248 Sun, 6 Aug 2023 11:55:02 GMT
.CATEGORY Fun
#>

#Requires -Version 5.1

param([string]$currency = "USD")

function ListExchangeRates { param([string]$currency)
	[xml]$ExchangeRates = (invoke-webRequest -uri "http://www.floatrates.com/daily/$($currency).xml" -userAgent "curl" -useBasicParsing).Content 
	foreach($Row in $ExchangeRates.channel.item) {
		New-Object PSObject -Property @{ Timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss"); 'Rate' = "$($Row.exchangeRate)"; 'Currency' = "$($Row.targetCurrency) - $($Row.targetName)"; 'Inverse' = "$($Row.inverseRate)"; 'Date' = "$($Row.pubDate)" }
	}
}

try {
	""
	"Current Exchange Rates for 1 $currency (source: http://www.floatrates.com)"
	"================================"

	ListExchangeRates $currency | format-table -property Rate,Currency,Inverse,Date
	exit 0
} catch {
throw
}

#Requires -Version 5.1

<#
.SYNOPSIS
    User Management: Retrieves COVID-19 statistics by country
.DESCRIPTION
    Fetches hourly updated COVID-19 statistics by country from the RapidAPI COVID-19 Data API.
.PARAMETER RapidApiKey
    X-RapidAPI-Key. Register for a free key at https://rapidapi.com
.PARAMETER Countries
    Names of countries to query. Use 'Show All' for all countries.
.PARAMETER ShowTotals
    Include global totals
.EXAMPLE
    PS> ./Get-CovidData.ps1 -RapidApiKey "your-key" -Countries "Germany", "USA" -ShowTotals
.CATEGORY User Management
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$RapidApiKey,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Show All', 'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan',
        'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi',
        'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada', 'CAR', 'Chad', 'Chile', 'China', 'Colombia', 'Comoros', 'Congo', 'Costa Rica', "Cote d'Ivoire", 'Croatia', 'Cuba', 'Cyprus', 'Czechia', 'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic',
        'Ecuador', 'Egypt', 'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Fiji', 'Finland', 'France',
        'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana', 'Haiti', 'Honduras', 'Hungary',
        'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati', 'Kuwait', 'Kyrgyzstan',
        'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg',
        'Madagascar', 'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania', 'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar',
        'Namibia', 'Nauru', 'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'N. Korea', 'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palau', 'Palestine', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal',
        'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles',
        'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa', 'S. Korea', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Sweden', 'Switzerland', 'Syria',
        'Taiwan', 'Tajikistan', 'Tanzania', 'Thailand', 'Timor-Leste', 'Togo', 'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu', 'Uganda', 'Ukraine', 'UAE', 'UK', 'USA', 'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe')]
    [string[]]$Countries = @('Germany'),

    [switch]$ShowTotals
)

Process {
    try {
        $result = @()
        $headers = @{
            'x-rapidapi-host' = 'covid-19-data.p.rapidapi.com'
            'x-rapidapi-key'  = $RapidApiKey
        }

        $restParam = @{
            Method  = 'Get'
            Headers = $headers
        }

        if ($ShowTotals) {
            $response = Invoke-RestMethod @restParam -Uri 'https://covid-19-data.p.rapidapi.com/totals?format=undefined' -ErrorAction Stop
            $result += [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Country   = 'Total'
                Confirmed = $response.confirmed
                Recovered = $response.recovered
                Critical  = $response.critical
                Deaths    = $response.deaths
            }
        }

        if ($Countries -contains 'Show All') {
            $Countries = $MyInvocation.MyCommand.Parameters['Countries'].Attributes.Where({ $_ -is [System.Management.Automation.ValidateSetAttribute] }).ValidValues
        }

        $uri = "https://covid-19-data.p.rapidapi.com/country?format=undefined&name={0}"
        foreach ($item in $Countries) {
            if ($item -like 'Show All') { continue }
            $response = Invoke-RestMethod @restParam -Uri ([System.String]::Format($uri, $item)) -ErrorAction Stop
            $result += [PSCustomObject]@{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Country   = $response.Country
                Confirmed = $response.confirmed
                Recovered = $response.recovered
                Critical  = $response.critical
                Deaths    = $response.deaths
            }
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}

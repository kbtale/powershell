#Requires -Version 5.1

<#
.SYNOPSIS
    Reporting: Generates an HTML report from Pester test results
.DESCRIPTION
    Parses a Pester test result XML file and converts it to an HTML report.
.PARAMETER Report
    Path to the Pester test report XML file
.EXAMPLE
    PS> ./Get-PesterReport.ps1 -Report "C:\Tests\results.xml" | Out-File report.html
.CATEGORY Reporting
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Report
)

Process {
    try {
        if (-not (Test-Path -Path $Report)) { throw "Report file '$Report' not found" }

        [xml]$xmlReport = Get-Content -Path $Report -ErrorAction Stop

        $html = @'
<html><head><style>body{font-family:Arial;margin:20px} .pass{color:green} .fail{color:red;font-weight:bold} table{border-collapse:collapse;width:100%} th,td{border:1px solid #ddd;padding:8px;text-align:left} th{background-color:#4CAF50;color:white}</style></head><body>
'@
        $html += '<h1>Pester Test Report</h1>'
        $html += "<p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>"
        $html += '<table><tr><th>Suite</th><th>Test</th><th>Result</th><th>Time</th></tr>'

        $suiteNodes = $xmlReport.SelectNodes('//testsuite')
        foreach ($suite in $suiteNodes) {
            $suiteName = $suite.Attributes['name'].Value
            $testNodes = $suite.SelectNodes('.//testcase')
            foreach ($test in $testNodes) {
                $testName = $test.Attributes['name'].Value
                $time = $test.Attributes['time'].Value
                $failure = $test.SelectSingleNode('failure')
                $result = if ($failure) { '<span class="fail">FAIL</span>' } else { '<span class="pass">PASS</span>' }
                $html += "<tr><td>$suiteName</td><td>$testName</td><td>$result</td><td>$($time)s</td></tr>"
            }
        }
        $html += '</table></body></html>'

        Write-Output $html
    }
    catch { throw }
}

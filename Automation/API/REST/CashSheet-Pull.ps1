$exePath = "C:\Program Files (x86)\RTI\RTIconnect\RTICmdLine.exe"

# Get the current month and year
$now = Get-Date
$year = $now.Year
$month = $now.Month

# Calculate the first day of the month
$firstDayOfMonth = Get-Date -Year $year -Month $month -Day 1

# Calculate the end date (the day before the first day of the current month)
$endDate = $firstDayOfMonth.AddDays(-1)

# Initialize the counter variable
$counter = -1

do {
    $arguments = "/User=******** /Password=****** /Domain=*** /ActionCode=ExportCashSheet /Summarize=FALSE /ReExport=TRUE /Vendor=ALL /Store=ALL /BeginDate=$counter /EndDate=$endDate /ExportFolder=C:\Users\Auditor\Downloads\ /ExportFile=Cash.csv "
    $logPath = Join-Path -Path (Split-Path -Path $exePath) -ChildPath "error.log"
    
    Start-Process -FilePath $exePath -ArgumentList $arguments -RedirectStandardError $logPath -ErrorVariable errors
    
    if ($errors) {
        $errorMessage = $errors[0].ToString()
        Write-Host "An error occurred: $errorMessage"
    }
    
    $counter--
}
until (!$errors)

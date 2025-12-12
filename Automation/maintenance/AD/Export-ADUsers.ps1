# Export-ADUsers.ps1

$exportPath = "$env:USERPROFILE\Desktop\ADUsers.csv"
Get-ADUser -Filter * -Property Name, EmailAddress, Department, Enabled |
Select-Object Name, EmailAddress, Department, Enabled |
Export-Csv -NoTypeInformation -Path $exportPath

Write-Host "Exported AD users to $exportPath"

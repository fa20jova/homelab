# Export-ADUsers.ps1
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$exportPath = "$env:USERPROFILE\Documents\ADUsers-$timestamp.csv"

try {
    Get-ADUser -Filter * -Property Name, EmailAddress, Department, Enabled |
        Select-Object Name, EmailAddress, Department, Enabled |
        Export-Csv -NoTypeInformation -Path $exportPath

    Write-Output "✅ Exported AD users to: $exportPath"
} catch {
    Write-Error "❌ Failed to export AD users: $_"
}

# detailed report on all SPO sites to CSV

$passwordPath = "C:\Users\$env:USERNAME\Documents\scripts\cred"
$reportDataPath = "C:\Users\$env:USERNAME\Documents\reports\SPO"
$adminUPN = "SPO_Admin@kar1.onmicrosoft.com"
$adminUrl = "https://kar1-admin.sharepoint.com"
$storageLimit   = 25 # MB
$storageWarning = 20 # MB

#Get-ExecutionPolicy
#Set-ExecutionPolicy RemoteSigned
#Set-ExecutionPolicy RemoteSigned

if (Test-Path "$env:CommonProgramFiles\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll") {
    Add-Type -Path (Resolve-Path "$env:CommonProgramFiles\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll")
    Add-Type -Path (Resolve-Path "$env:CommonProgramFiles\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll")
    Add-Type -Path (Resolve-Path "$env:CommonProgramFiles\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.WorkflowServices.dll")
} else {
    Write-Host "download SharePoint Online Client Components SDK from: https://www.microsoft.com/en-us/download/details.aspx?id=42038"
    Start-Sleep 5
    Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=42038"
}

$passwordPath.TrimEnd("\")
$reportDataPath.TrimEnd("\")

if (Test-Path $passwordPath) {} else {md $passwordPath}
if (Test-Path $reportDataPath) {} else {md $reportDataPath}


$pwFile = "$passwordPath\controlpoint.dat"

$pwFileObject = Get-Item $pwFile -ErrorAction SilentlyContinue
if (-not $pwFileObject ) {
    $userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."
    $userCredential.Password | ConvertFrom-SecureString | Out-File $pwFile 
}

$secPw = Get-Content $pwFile | ConvertTo-SecureString
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUPN, $secPw ;  
$ccred = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($adminUPN, $secPw)


$cred.GetType()
$ccred.GetType()

$cred 
$ccred

Connect-SPOService -Url $adminUrl -Credential $cred

$time1 = Get-Date
if ($sites.Count -gt 0) {} else {
    #$sites = Get-SPOSite $siteUrl ;     
    #$sites = Get-SPOSite -Limit 10
    $sites = Get-SPOSite  -Limit All 
}
$time2 = Get-Date
$sitesReport = @()
$i = 0;
foreach ($s in $sites) {
    Write-Host ($i++) / $sites.Count " :" -NoNewline
    $s.Url
    $site = Get-SPOSite -Identity $s.Url -Detailed

    $siteReport = New-Object -TypeName System.Object
    $siteReport | Add-Member -Type NoteProperty -Name "Site" -Value $site.Url
    $siteReport | Add-Member -Type NoteProperty -Name "SiteStatus" -Value $site.Status
    $siteReport | Add-Member -Type NoteProperty -Name "Owner" -Value $site.Owner
    $siteReport | Add-Member -Type NoteProperty -Name "SiteStorageQuota" -Value $site.StorageQuota
    $siteReport | Add-Member -Type NoteProperty -Name "LastContentModifiedDate" -Value $site.LastContentModifiedDate
    $siteReport | Add-Member -Type NoteProperty -Name "SiteTemplate" -Value $site.Template
    
    $siteReport | Add-Member -Type NoteProperty -Name "ResourceUsageAverage" -Value $site.ResourceUsageAverage
    $siteReport | Add-Member -Type NoteProperty -Name "StorageUsageCurrent" -Value $site.StorageUsageCurrent
    $siteReport | Add-Member -Type NoteProperty -Name "LockIssue" -Value $site.LockIssue
    
    $sitesReport += $siteReport
}
$time3 = Get-Date

$newReportFile = $reportDataPath + "\Site_Collections_SPO_detailed_report_" + $((Get-Date -Format "DyyyyMMddTHHmm")) + ".csv"; $newReportFile 
$sitesReport | Export-Csv -LiteralPath $newReportFile -NoTypeInformation

$time4 = Get-Date

Write-Host ($time2-$time1)
Write-Host ($time3-$time2)
Write-Host ($time4-$time1)

#return
$sitesReport | ft -AutoSize

$sitesAtRisk = $sitesReport | ?{$_.StorageUsageCurrent -gt $storageWarning}
$sitesAtRisk | ft -AutoSize






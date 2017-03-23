# --------------------------------------------------------------
#
# Syndication Check - Single tenant.ps1
#
# --------------------------------------------------------------
#
# Check Office 365 tenant and determine if still under 
# syndication model or moved to CSP.
# 
# Note - applies to Australia only. Syndication in other 
#        countries may mean something different.
#
# --------------------------------------------------------------

function MSOLConnected {
    Get-MsolDomain -ErrorAction SilentlyContinue | out-null
    $result = $?
    return $result
}

$cred = Get-Credential
$connect = Connect-MsolService -Credential $cred

# if connection fails, exit.
if(-not (MSOLConnected)) {
    exit
}

$count = Get-MsolAccountSku | where { $_.AccountName -eq "syndication-account" } | measure

if($count.Count -eq 0) {
    Write-Host "Tenant has been moved to CSP." -ForegroundColor Green
    
}
else {
    Write-Host "Tenant still syndicated and has not been moved to CSP." -ForegroundColor Red
}
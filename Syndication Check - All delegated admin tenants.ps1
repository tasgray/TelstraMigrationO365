# --------------------------------------------------------------
#
# TelstraCheck.ps1
#
# --------------------------------------------------------------
#
# Using delegated administrator credentials, checks each 
# tenant and determines if syndicated with Telstra. Results
# are displayed in a gridview for easy filtering and sorting.
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

$tenantArray = @()

$cred = Get-Credential
Connect-MsolService -Credential $cred

# if connection fails, exit.
if(-not (MSOLConnected)) {
    exit
}

# Get list of tenants & loop
Get-MsolPartnerContract -All | ForEach { 
    
    $tenantDetails = @{}
    $tenantDetails.Tenant = [string]$_.DefaultDomainName
    $tenantDetails.Syndicated = "No"
    
    Get-MsolAccountSku -TenantId $_.TenantId.Guid | Foreach { if($_.AccountName -eq "syndication-account") { $tenantDetails.Syndicated = "Yes" } }
     
    $tenantArray += New-Object -TypeName PSObject -Prop $tenantDetails

}

$tenantArray | Sort-Object -Property Syndicated -Descending | Out-GridView
Import-Module ..\Library\Utils.psm1


Write-Host "Use this script to transition Office 365 tenants from Telstra Apps Marketplace."
Write-Host "Before running this script, please ensure that you have purchased additional subscriptions to replace those provided by Telstra."

$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential
$domain = Get-MsolDomain | Where-Object { $_.IsDefault -eq $true }
$csv_file = "User Licenses - $($domain.Name).csv"

$confirm = ""
$insufficientlicense = $false
$existing_user_licenses = @{}

$underprovisionedlicenses = New-Object System.Collections.ArrayList


# Get all licensed users and store
Get-MsolUser | Where-Object { $_.isLicensed -eq "TRUE" }  | ForEach-Object { 
   $existing_user_licenses.Add($_.UserPrincipalName, $_.Licenses)
} 

Write-Host "Exporting existing users and licenses to CSV - $($csv_file)"
$existing_user_licenses.GetEnumerator() | Sort-Object Name | Select Name, @{Name='Value';Expression={[string]::join(";",($_.Value.AccountSkuId))}} | Export-Csv $csv_file

Get-MsolAccountSku | ForEach-Object {
    
    if($_.ActiveUnits -lt ($_.ConsumedUnits * 2)) {
        
        $license_error = New-Object System.Object
        $license_error | Add-Member -MemberType NoteProperty -Name "License" -Value $_.AccountSkuId
        $license_error | Add-Member -MemberType NoteProperty -Name "Available" -Value $_.ActiveUnits
        $license_error | Add-Member -MemberType NoteProperty -Name "Consumed" -Value $_.ConsumedUnits
        $license_error | Add-Member -MemberType NoteProperty -Name "Required" -Value ($_.ConsumedUnits * 2)
        $license_error | Add-Member -MemberType NoteProperty -Name "Difference" -Value ($_.ActiveUnits - ($_.ConsumedUnits * 2))
        $underprovisionedlicenses.Add($license_error) | Out-Null

        $insufficientlicense = $true;

    }

}



Write-Host "Insufficient Licenses? $(YesNo($insufficientlicense))"

if($insufficientlicense) {
    $underprovisionedlicenses | Format-Table *

    while((Read-Host -Prompt "Insufficient subscriptions are available. Are you sure you wish to continue? Type 'yes' to proceed").ToLower() -ne "yes")
    {}
}

Write-Host "Licensed user information has been stored. I'll keep an eye on subscriptions while you begin cancelling and replace them for you..."
Write-Host "Re-assigning licenses to users..."

# Get users and loop 
While($true) {
    Get-MsolUser | ForEach-Object {
        
        # assign msol user for use later
        $current_user = $_

        # for each user, compare licenses to hashtable
        if($existing_user_licenses.ContainsKey($current_user.UserPrincipalName)) { 
     
            # loop stored licenses
            $existing_user_licenses.Get_Item($current_user.UserPrincipalName) | ForEach-Object {
                
                $sku = $_.AccountSkuId
                
                #see if it exists in the current users licenses
                if( @($current_user.Licenses.Where({ $_.AccountSkuId -eq $sku })).Count -ne 1) {
                    Write-Host "$($current_user.UserPrincipalName) license has been removed. Please wait while I add it back.."
                    Write-Host "Assigning $($sku) to $($current_user.UserPrincipalName)"
                    Set-MsolUserLicense -UserPrincipalName $current_user.UserPrincipalName -AddLicenses $sku
                }
            }
        }
    }

    #write-host "sleep start"
    start-sleep 3
    #write-host "sleep finish"
}    
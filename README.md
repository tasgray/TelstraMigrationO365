# Telstra Office 365 Tenant Migration - Powershell
Powershell scripts to assist Microsoft CSP partners with Office 365 tenant transition away from Telstra Apps Marketplace.
For detailed instructions on how to migrate Office 365 customers away from Telstra Apps Marketplace refer to http://tasgray.com/migrate-office365-from-telstra/ 

### Syndication Check - All delegated admin tenants.ps1	
Use this script to determine which Office 365 tenants are syndicated and those which have been transitioned to CSP.

Requires - Global admin credentials for delegated admin partner 

### Syndication Check - Single tenant.ps1
Use this script to determine if an Office 365 tenant is syndicated or has been transitioned to CSP.

Requires - Global admin credentials for tenant

### Transition Telstra Tenant.ps1
Use this script to simplify the reassignment of Office 365 licenses which are removed by Telstra Apps Marketplace during a transition. 

Requires - Global admin credentials for transitioning tenant


#https://docs.microsoft.com/en-us/microsoft-365/enterprise/remove-licenses-from-user-accounts-with-microsoft-365-powershell?view=o365-worldwide
<#

.SYNOPSIS
    Used to remove licences for all users based off of their
    SKUPartNumber
  
.DESCRIPTION
    Very hacky and gross way to go about what I did. This can be
    re-written MUCH more efficiently, I just needed something to 
    do exactly what I did right now.

    The intention is to remove a licence from all users and then
    replace it with specified users from CSV.

    This will connect to Microsoft Graph, set a variable for the 
    SKU Part Number, and then  get all users where the SKUPartNumber
     is set and remove it.

    The second part will then import UserPrincipalName from CSV 
    under the UserPrincipalName Column and then apply a that same
    licence to those users.

  
.PARAMETER <path>
    Change the path in line 55 to where your CSV is located. This
    script is looking for the column name "UserprincipalName" in your CSV

.PARAMETER <SkuPartNumber>
    Change this to what SkuPartNumber you want to remove.
 
.NOTES
  Version:        0.1
  Author:         Taylor Hassall
  Creation Date:  25/05/2022
  Last Modified:  25/05/2022
 
.LINK
    SKU's: https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference
    Code: https://docs.microsoft.com/en-us/microsoft-365/enterprise/view-licensed-and-unlicensed-users-with-microsoft-365-powershell?view=o365-worldwide

    
.EXAMPLE
    N/A

#>

#Conenct to Microsoft Graph Powershell with required scopes.
Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All

#Sets the Variable for the SKU to search for, in this case Microsoft 365 Audio Conferencing
$LicenceSKU = Get-MgSubscribedSku -All | Where SkuPartNumber -eq '<SkuPartNumber>'

#Get all Users with the SKU Above Assigned, and count it.
$licencedUser=Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq $($LicenceSKU.SkuId) )" -ConsistencyLevel eventual -CountVariable LicenceSKUUserCount -All

#Write how many users were found with this Licence
Write-Host "Found $LicenceSKUUserCount MCOMEETADV licensed users."

#Loop through the users found in the $LicencedUser variable and remove the licence set in $LicenceSKU
foreach($user in $licensedUsers)
{
    $licencesToRemove = $user.AssignedLicenses | Select -ExpandProperty SkuId
    $user = Set-MgUserLicense -UserId $user.UserPrincipalName -RemoveLicenses @($LicenceSKU.SkuId) -AddLicenses @{} -WhatIf
}

#Write how many licences removed
Write-Host "Removed $LicenceSKU Licence from $LicenceSKUUserCount accounts"
Write-Host "Adding licences to users from CSV"

Import-CSV "<PATH>" | Foreach {
    $upn=$_.UserprincipalName; Set-MgUserLicense -UserId $upn -AddLicenses @{SkuId = $LicenceSKU.SkuId} -RemoveLicenses @() -whatif
    }
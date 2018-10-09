<#
  .SYNOPSIS
  SetStorageAccountNameIntoSecret
  
  .DESCRIPTION
  SetStorageAccountNameIntoSecret
  
  .INPUTS
  SetStorageAccountNameIntoSecret - The name of SetStorageAccountNameIntoSecret

  .OUTPUTS
  None
  
  .EXAMPLE
  SetStorageAccountNameIntoSecret

  .EXAMPLE
  SetStorageAccountNameIntoSecret


#>

# https://docs.microsoft.com/en-us/powershell/module/azurerm.resources/?view=azurermps-6.9.0
# https://docs.microsoft.com/en-us/powershell/module/azurerm.storage/get-azurermstorageaccountkey?view=azurermps-6.9.0

Import-Module AzureRM
Import-Module AzureRM.Storage
Import-Module AzureRM.Profile

function SetStorageAccountNameIntoSecret()
{
  [CmdletBinding()]
  param
  (
    [parameter (Mandatory = $true) ]
    [ValidateNotNull()]
    $config
  )

  Write-Verbose 'SetStorageAccountNameIntoSecret: Starting'

  $resourceGroup = $($config.azure.resourceGroup)
  Write-Host "Resource Group: $resourceGroup"
  $customerid = $($config.customerid)
  Write-Host "CustomerID: $customerid"

  $storageAccountName = $(GetStorageAccountName -resourceGroup $resourceGroup).StorageAccountName

  Write-Host "Get storage account key"
  $storageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup -AccountName $storageAccountName).Value[0]
  
  # Write-Host "Storagekey: [$STORAGE_KEY]"

  Write-Host "Creating kubernetes secret for Azure Storage Account: azure-secret"
  $secretname = "azure-secret"
  $namespace = "default"

  DeleteSecret -secretname $secretname -namespace $namespace

  CreateSecretWithMultipleValues -secretname $secretname -namespace $namespace -secret1 "resourcegroup=${resourceGroup}" -secret2 "azurestorageaccountname=${storageAccountName}" -secret3 "azurestorageaccountkey=${storageKey}"
  
  Write-Verbose 'SetStorageAccountNameIntoSecret: Done'
}

Export-ModuleMember -Function "SetStorageAccountNameIntoSecret"
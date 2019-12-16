#login to your azure account
Login-AzAccount
Get-AzSubscription

Select-AzSubscription -Subscription "vakappas - Internal Consumption"

#Deploy VM to Azure using Template
# Create a Resource Group
$RG = "Hub-Spoke-On-Prem-rg"
$Location = "West Europe"
## $url="https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/Hub-net-2-firewalls-1-router/hub-vnet.json"

## url=https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/master/spoke-vnet.json
$url="https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/Hub-Spoke-On-Prem/Hub-Spoke-On-Prem-master.json"

New-AzResourceGroup -Name $RG -Location $Location

$cred = Get-Credential
$templateParameters = @{

    adminUsername = $cred.UserName
    adminPassword = $cred.Password

}


New-AzResourceGroupDeployment -Name OnPremHubSpoke -ResourceGroupName $RG -TemplateUri $url -TemplateParameterObject $templateParameters
#connect to VM using RDP
    mstsc /v:((Get-AzPublicIpAddress -ResourceGroupName $rg).IpAddress)

Remove-AzResourceGroup -Name $RG -Force

# Create Managed Disk from uploaded VHD

# Initialize variables
$storageType = "StandardSSD_LRS"
$location = "West Europe"
$storageAccountId = "/subscriptions/c5807190-2d73-4214-a65b-2416635845b8/resourceGroups/CloudStorage-RG/providers/Microsoft.Storage/storageAccounts/vklabsa"
$sourceVhdUri = "https://vklabsa.blob.core.windows.net/images/pfSense-2-4-4-OS.vhd"
## New-AzureRmResourceGroup -Name eu-firewalls-rg -Location 'West Europe'
$RG = "Hub-Spoke-On-Prem-rg"
$DiskName = "onpremFW-os-disk"
$vnet = "on-prem-vnet"
$VMname = "OnPremFW"

# Create the disk configuration
$diskConfig = New-AzDiskConfig -AccountType $storageType -Location $location -CreateOption Import -StorageAccountId $storageAccountId -SourceUri $sourceVhdUri
# Create the Managed Disk
New-AzDisk -Disk $diskConfig -ResourceGroupName $RG -DiskName $DiskName


## Create a VM with that Disk (pfSense NVA)

# Get the object of the existing Managed Disk
$disk = Get-AzDisk -DiskName $DiskName -ResourceGroupName $RG
# Get the object for the existing Virtual Network
$VirtualNetwork = Get-AzVirtualNetwork -Name $vnet -ResourceGroupName $RG
# Create a new Virtual Machine object
$virtualMachine = New-AzVMConfig -VMName $VMname -VMSize "Standard_D2s_v3"
# Attach the existing Managed Disk to the Virtual Machine
$virtualMachine = Set-AzVMOSDisk -VM $virtualMachine -ManagedDiskId $disk.Id -CreateOption Attach -Linux

<# The following two cmdlets are to create new NICs
# Create the NIC's for the frontend and the backend
$frontEndNic = New-AzNetworkInterface -Name eu-pfsense-1-frontend-nic -ResourceGroupName eu-firewalls-rg -Location 'West Europe' -SubnetId $VirtualNetwork.Subnets[1].Id -PrivateIpAddress 10.0.0.36
$backEndNic = New-AzureRmNetworkInterface -Name eu-pfsense-1-backend-nic -ResourceGroupName eu-firewalls-rg -Location 'West Europe' -SubnetId $VirtualNetwork.Subnets[2].Id -PrivateIpAddress 10.0.0.68
#>
$frontEndNic = Get-AzNetworkInterface -Name OnPremFW-1-nic0 -ResourceGroupName $RG 
$backEndNic = Get-AzNetworkInterface -Name OnPremFW-1-nic1 -ResourceGroupName $RG

# Add the NIC's to the Virtual Machine
$virtualMachine = Add-AzVMNetworkInterface -VM $virtualMachine -Id $frontEndNic.Id -Primary
$virtualMachine = Add-AzVMNetworkInterface -VM $virtualMachine -Id $backEndNic.Id

# Create the Virtual Machine
New-AzVM -VM $virtualMachine -ResourceGroupName $RG -Location 'West Europe'

#Working with Images
$loc = 'westeurope' #first set a location
#View the templates available
Get-AzVMImagePublisher -Location $loc #check all the publishers available
Get-AzVMImageOffer -Location $loc -PublisherName "MicrosoftWindowsServer" #look for offers for a publisher
Get-AzVMImageSku -Location $loc -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" #view SKUs for an offer
Get-AzVMImage -Location $loc -PublisherName "cisco" -Offer "cisco-ftdv" -Skus "ftdv-azure-byol" #pick one!

#Accept the terms
$agreementTerms=Get-AzMarketplaceterms -Publisher "cisco" -Product "cisco-csr-1000v" -Name "csr-azure-byol"

Set-AzMarketplaceTerms -Publisher "cisco" -Product "cisco-csr-1000v" -Name "csr-azure-byol" -Terms $agreementTerms -Accept
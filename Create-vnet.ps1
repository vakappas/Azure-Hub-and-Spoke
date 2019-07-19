#login to your azure account
Login-AzAccount
Get-AzSubscription

Select-AzSubscription -Subscription "vakappas - Internal Consumption"

#Deploy VM to Azure using Template
# Create a Resource Group
$RG = "pfSense-rg"
$Location = "West Europe"
## $url="https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/Hub-net-2-firewalls-1-router/hub-vnet.json"

## url=https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/master/spoke-vnet.json
$url="https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/Hub-Spoke-On-Prem/hub-vnet.json"

New-AzResourceGroup -Name $RG -Location $Location

$cred = Get-Credential
$templateParameters = @{

    adminUsername = $cred.UserName
    adminPassword = $cred.Password
    nvaType = "pfSense"

}


New-AzResourceGroupDeployment -Name OnPremHubSpoke -ResourceGroupName $RG -TemplateUri $url -TemplateParameterObject $templateParameters
#connect to VM using RDP
    mstsc /v:((Get-AzPublicIpAddress -ResourceGroupName $rg).IpAddress)

Remove-AzResourceGroup -Name $RG -Force

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


# Change VM Size
$VMList = Get-AzVm | Out-GridView -OutputMode Multiple -Title ‘Please select an Azure Virtual Machine to resize.’; 
$TargetSize = Get-AzVmSize -Location westeurope | Out-GridView -OutputMode Single -Title ‘Please select a target Azure Virtual Machine size.’; 
foreach ($VM in $VMList) { 
  Write-output "Resizing Microsoft Azure Virtual Machine" $VM.Name "in Resource Group" $VM.ResourceGroupName "to size" $TargetSize 
  $VM.HardwareProfile.VmSize = "Standard_D2s_v3"
  Update-AzVm -VM $VM -ResourceGroupName $VM.ResourceGroupName -Verbose 
} 


# Create the Azure Log Analytics Workspace

New-AzResourceGroupDeployment -Name Monitor -ResourceGroupName $RG -TemplateFile .\ConfigureWorkspaceTemplate.json -TemplateParameterFile .\ConfigureWorkspaceParameters.json

.\Install-VMInsights.ps1 -WorkspaceRegion westeurope -WorkspaceId "6efc4c9f-02ea-460d-9655-f9ce7f164976" -WorkspaceKey "5E9ovO9PhfdXntUufu648IwGrgb0tHsmzUp19vxNG9RXWPU3Kh98Kto2ytriU97MF05/fUMCcfN9NMCod0MOKw==" 
-SubscriptionId "c5807190-2d73-4214-a65b-2416635845b8" -ResourceGroup "Hub-Spoke-On-Prem-rg"
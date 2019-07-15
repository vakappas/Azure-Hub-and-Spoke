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
$url="https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/Hub-Spoke-On-Prem/on-prem-vnet.json"

New-AzResourceGroup -Name $RG -Location $Location

$cred = Get-Credential
$templateParameters = @{

    adminUsername = $cred.UserName
    adminPassword = $cred.Password
    nvaType = "ubuntu"
    domainName = "vklab.local"
    DCvmSize = "Standard_D2s_v3"

}


New-AzResourceGroupDeployment -Name hub -ResourceGroupName $RG -TemplateUri $url -TemplateParameterObject $templateParameters
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
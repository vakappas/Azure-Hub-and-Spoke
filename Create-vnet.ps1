#login to your azure account
Login-AzAccount
Get-AzSubscription

Select-AzSubscription -Subscription "vakappas - Internal Consumption"

#Deploy VM to Azure using Template
# Create a Resource Group
$RG = "IPIP-LAB-RG"
$Location = "West Europe"
$url="https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/Two-VNETs-Two-VMs/Two-VNETs.json"

## url=https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/master/spoke-vnet.json
$url="https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/master/Hub-and-Spoke.json"

New-AzResourceGroup -Name $RG -Location $Location

$cred = Get-Credential
$templateParameters = @{

    adminUsername = $cred.UserName
    adminPassword = $cred.Password

}


New-AzResourceGroupDeployment -Name ipiplab -ResourceGroupName $RG -TemplateUri $url -TemplateParameterObject $templateParameters
#connect to VM using RDP
    mstsc /v:((Get-AzPublicIpAddress -ResourceGroupName $rg).IpAddress)

Remove-AzResourceGroup -Name $RG -Force

#Working with Images
$loc = 'westeurope' #first set a location
#View the templates available
Get-AzVMImagePublisher -Location $loc #check all the publishers available
Get-AzVMImageOffer -Location $loc -PublisherName "openlogic" | Get-AzVMImageSku #look for offers for a publisher
Get-AzVMImageSku -Location $loc -PublisherName "canonical" -Offer "UbuntuServer" #view SKUs for an offer
Get-AzVMImage -Location $loc -PublisherName "canonical" -Offer "UbuntuServer" -Skus "16.04.0-LTS" #pick one!

#Accept the terms
$agreementTerms=Get-AzMarketplaceterms -Publisher "Canonical" -Product "UbuntuServer" -Name "16.04.0-LTS"
Set-AzMarketplaceTerms -Publisher "cisco" -Product "cisco-csr-1000v" -Name "csr-azure-byol" -Terms $agreementTerms -Accept


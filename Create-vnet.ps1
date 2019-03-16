#login to your azure account
Login-AzAccount
Get-AzSubscription

Select-AzSubscription -Subscription "vakappas - Internal Consumption"

#Deploy VM to Azure using Template
# Create a Resource Group
$RG = "hub-and-spoke-rg"
$Location = "West Europe"
$url="https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/master/hub-vnet.json"

## url=https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/master/spoke-vnet.json
$url="https://raw.githubusercontent.com/vakappas/Azure-Hub-and-Spoke/master/Hub-and-Spoke.json"

New-AzResourceGroup -Name $RG -Location $Location

$cred = Get-Credential
$templateParameters = @{

    adminUsername = $cred.UserName
    adminPassword = $cred.Password

}


New-AzResourceGroupDeployment -Name hub -ResourceGroupName $RG -TemplateUri $url -TemplateParameterObject $templateParameters
#connect to VM using RDP
    mstsc /v:((Get-AzPublicIpAddress -ResourceGroupName $rg).IpAddress)

Remove-AzResourceGroup -Name $RG -Force
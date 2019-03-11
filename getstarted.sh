# Deploy lab
url=https://raw.githubusercontent.com/vakappas/Azure-LISP/two-subnets/lisp_lab_iterate_through_vnet.json

rg=lisp-lab
az group create -n $rg -l westeurope
az group deployment create -g $rg --template-uri $url --parameters '{"adminPassword":{"value":"P@ssw0rd@2019"}}'

# Check Public IP addresses
az network public-ip list -g $rg --query [].[name,ipAddress] -o tsv

# Setting the default RG
az configure --defaults group=$rg

# List all vnets
az network vnet list -g $rg -o table

# List all subnets
az network vnet subnet list --vnet-name onprem-vnet -o table
az network vnet subnet list --vnet-name azure-vnet -o table

# Stoping VMs
az vm deallocate --ids $(az vm list -g $rg --query "[].id" -o tsv)


# Cleanup
az group delete -n $rg -y --no-wait

# Starting VMs
az vm start --ids $(az vm list -g $rg --query "[].id" -o tsv)

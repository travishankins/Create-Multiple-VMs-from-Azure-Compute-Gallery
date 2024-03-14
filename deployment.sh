az deployment group create \
  --name MyDeployment \
  --resource-group <YourResourceGroupName> \
  --template-file <path-to-your-bicep-file>.bicep \
  adminPassword='<YourSecurePassword>'
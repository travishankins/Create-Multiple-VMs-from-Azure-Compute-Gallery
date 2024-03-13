az deployment group create \
  --resource-group myExistingVNetResourceGroup \
  --template-file ./path_to_your_bicep_file.bicep \
  --parameters adminPassword=<YourSecurePassword>

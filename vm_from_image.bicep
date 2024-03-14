// Parameters for deployment configuration
param vmNamePrefix string = 'myVM' // Prefix for VM names
param vmCount int = 10 // Number of VMs to create
param location string = 'East US' // Deployment region
param vmSize string = 'Standard_DS1_v2' // Size of the VMs
param adminUsername string = 'azureuser' // Username for the VM administrator account
param adminPassword string // Admin password for the VMs. Consider using a secure string in production
param existingVnetResourceGroup string = 'myExistingVNetResourceGroup' // Resource group of the existing VNet
param existingVnetName string = 'myExistingVNet' // Name of the existing VNet
param existingSubnetName string = 'myExistingSubnet' // Name of the subnet in the existing VNet
param subscriptionId string = '<subscriptionId>' // Subscription ID for the Azure account
param galleryResourceGroup string = '<galleryResourceGroup>' // Resource group where the ACG is located
param galleryName string = '<galleryName>' // Name of the Azure Compute Gallery
param imageDefinition string = '<imageDefinition>' // Image definition within the ACG
param imageVersion string = '<imageVersion>' // Specific version of the image to use

// Constructing the full resource ID for the ACG image version
var acgImageId = '/subscriptions/${subscriptionId}/resourceGroups/${galleryResourceGroup}/providers/Microsoft.Compute/galleries/${galleryName}/images/${imageDefinition}/versions/${imageVersion}'

// Constructing the subnet ID
var subnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', existingVnetResourceGroup, existingVnetName, existingSubnetName)

// Reference to the existing VNet (for context, not directly used in subnet referencing here)
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: existingVnetName
  scope: resourceGroup(existingVnetResourceGroup)
}

// Loop to create multiple VMs
resource virtualMachines 'Microsoft.Compute/virtualMachines@2021-07-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${format('{0:D2}', i + 1)}' // Generating VM name with a numeric suffix
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        id: acgImageId
      }
    }
    osProfile: {
      computerName: '${vmNamePrefix}${format('{0:D2}', i + 1)}' // Setting the computer name of the VM
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          name: '${vmNamePrefix}${format('{0:D2}', i + 1)}-nic'
          properties: {
            ipConfigurations: [
              {
                name: 'ipconfig1'
                properties: {
                  subnet: {
                    id: subnetId // Correctly reference the subnet ID
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
  dependsOn: [
    vnet
  ]
}]

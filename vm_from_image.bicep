// Parameters for deployment configuration
param vmNamePrefix string = 'myVM' // Prefix for VM names
param vmCount int = 1 // Number of VMs to create
param location string = 'South Central US' // Deployment region
param vmSize string = 'Standard_B4als_v2' // Size of the VMs
param adminUsername string = 'azureuser' // Username for the VM administrator account
param adminPassword string // Admin password for the VMs. Consider using a secure string in production
param existingVnetResourceGroup string = 'myExistingVNetResourceGroup' // Resource group of the existing VNet
param existingVnetName string = 'myExistingVNet' // Name of the existing VNet
param existingSubnetName string = 'myExistingSubnet' // Name of the subnet in the existing VNet
param subscriptionId string = 'MySubscriptionID' // Subscription ID for the Azure account
param galleryResourceGroup string = 'MyGalleryResourceGroup' // Resource group where the ACG is located
param galleryName string = 'MyGalleryName' // Name of the Azure Compute Gallery
param imageDefinition string = 'MyImageDefinition' // Image definition within the ACG
param imageVersion string = 'MyVersion' // Specific version of the image to use

// Constructing the full resource ID for the ACG image version
var acgImageId = '/subscriptions/${subscriptionId}/resourceGroups/${galleryResourceGroup}/providers/Microsoft.Compute/galleries/${galleryName}/images/${imageDefinition}/versions/${imageVersion}'

// Constructing the subnet ID
var subnetId = '/subscriptions/${subscriptionId}/resourceGroups/${existingVnetResourceGroup}/providers/Microsoft.Network/virtualNetworks/${existingVnetName}/subnets/${existingSubnetName}'

// Reference to the existing VNet (for context, not directly used in subnet referencing here)
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: existingVnetName
  scope: resourceGroup(existingVnetResourceGroup)
}

// Create NICs in a loop
resource nics 'Microsoft.Network/networkInterfaces@2022-01-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${format('{0:D2}', i + 1)}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}]

// Create VMs and associate with NICs
resource virtualMachines 'Microsoft.Compute/virtualMachines@2021-07-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}${format('{0:D2}', i + 1)}'
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
      computerName: '${vmNamePrefix}${format('{0:D2}', i + 1)}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nics[i].id
        }
      ]
    }
  }
  dependsOn: [
    nics[i] // Ensure each VM waits for its corresponding NIC to be created
  ]
}]

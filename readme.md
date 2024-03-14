# Azure VM Deployment with Bicep

This project contains a Bicep template for deploying a specified number of Virtual Machines (VMs) in Azure, using an image from an Azure Compute Gallery (ACG). The VMs are deployed into an existing Virtual Network (VNet) and subnet.

## Overview

The Bicep template automates the deployment of multiple VMs based on a custom image from an Azure Compute Gallery. This approach is beneficial for standardized and repeatable deployments within Azure, ensuring consistency across environments.

### Key Features

- **Scalability**: Easily adjust the number of VMs to deploy by changing a single parameter.
- **Customization**: Utilize custom images from Azure Compute Gallery for VM deployments, ensuring a consistent base configuration.
- **Networking**: Integrates with existing Azure networking infrastructure, deploying VMs into a specified VNet and subnet.
- **Automation**: Simplifies the process of large-scale VM deployments, reducing manual effort and potential for errors.

### Parameters

- `vmNamePrefix`: Prefix used for VM names, allowing for easy identification.
- `vmCount`: The number of VMs to create, providing scalability.
- `location`: The Azure region where the VMs will be deployed.
- `vmSize`: Specifies the size of the VMs, allowing for customization based on needs.
- `adminUsername`: Administrator username for the VMs.
- `adminPassword`: Administrator password for the VMs. Use a secure string in production.
- `existingVnetResourceGroup`: The resource group containing the existing VNet.
- `existingVnetName`: Name of the existing VNet where VMs will be connected.
- `existingSubnetName`: Specific subnet within the VNet for the VMs.
- `subscriptionId`, `galleryResourceGroup`, `galleryName`, `imageDefinition`, `imageVersion`: Parameters for specifying the ACG image to use for VMs.

### How It Works

The template constructs the full resource ID for the specified ACG image version and deploys VMs into an existing VNet and subnet. It uses a loop to create the number of VMs specified in the `vmCount` parameter, with each VM configured to use the selected ACG image. VM names are generated with a numeric suffix based on the `vmNamePrefix` and the iteration of the loop.

### Deployment

To deploy this Bicep template, use the Azure CLI or PowerShell with the appropriate parameters. Example Azure CLI command:

```bash
az deployment group create --resource-group <ResourceGroupName> --template-file ./vm-deployment.bicep --parameters @parameters.json
```

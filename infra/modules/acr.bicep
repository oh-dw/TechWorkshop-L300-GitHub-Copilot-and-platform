@description('Name of the Azure Container Registry.')
param name string

@description('Azure region for the registry.')
param location string

@description('SKU for the registry (Basic/Standard/Premium).')
param sku string = 'Basic'

@description('Resource tags.')
param tags object = {}

resource registry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  tags: tags
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

output id string = registry.id
output loginServer string = registry.properties.loginServer

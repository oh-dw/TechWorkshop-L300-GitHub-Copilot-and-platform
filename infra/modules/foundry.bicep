@description('Microsoft Foundry (AIServices) resource name.')
param name string

@description('Azure region for the Foundry resource.')
param location string

@description('SKU for Foundry (e.g. S0).')
param sku string = 'S0'

@description('Resource tags.')
param tags object = {}

resource foundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: name
  location: location
  kind: 'AIServices'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: sku
  }
  properties: {
    allowProjectManagement: true
    customSubDomainName: name
    disableLocalAuth: true
  }
}

output id string = foundry.id
output endpoint string = foundry.properties.endpoint

@description('Name of the App Service plan.')
param name string

@description('Azure region for the plan.')
param location string

@description('SKU object for the plan (name/tier/size/capacity).')
param sku object

@description('Resource tags.')
param tags object = {}

resource plan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  sku: sku
  kind: 'linux'
  tags: tags
  properties: {
    reserved: true
  }
}

output id string = plan.id

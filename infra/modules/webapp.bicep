@description('Web App name.')
param name string

@description('Azure region for the Web App.')
param location string

@description('Resource ID of the App Service plan.')
param planId string

@description('ACR login server (e.g. myacr.azurecr.io).')
param acrLoginServer string

@description('Fully qualified container image (e.g. myacr.azurecr.io/app:tag).')
param imageName string

@description('Optional Application Insights connection string.')
param appInsightsConnectionString string = ''

@description('Resource tags.')
param tags object = {}

resource site 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  kind: 'app,linux,container'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: planId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${imageName}'
      alwaysOn: false
      appSettings: concat([
        {
          name: 'WEBSITES_PORT'
          value: '8080'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
      ], empty(appInsightsConnectionString) ? [] : [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
      ])
    }
  }
}

output id string = site.id
output principalId string = site.identity.principalId
output defaultHostName string = site.properties.defaultHostName

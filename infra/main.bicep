
targetScope = 'resourceGroup'

@description('Short prefix for resource names, e.g. "zavastore".')
param namePrefix string = 'zavastore'

@description('Deployment environment moniker, e.g. dev/test/prod.')
param env string = 'dev'

@description('Azure location for all resources.')
param location string = 'westus3'

@description('Optional resource tags applied to all resources.')
param tags object = {}

@description('Azure Container Registry name (3-50 lowercase alphanumerics).')
param acrName string = toLower('${namePrefix}${env}acr')

@description('SKU for Azure Container Registry (Basic or Standard).')
param acrSku string = 'Basic'

@description('App Service plan name for the web app.')
param appServicePlanName string = '${namePrefix}-${env}-asp'

@description('App Service plan SKU object (name/tier/capacity).')
param appServicePlanSku object = {
  name: 'B1'
  tier: 'Basic'
  size: 'B1'
  capacity: 1
}

@description('Web App name (globally unique by default to avoid collisions).')
param webAppName string = toLower('${namePrefix}-${env}-web-${uniqueString(resourceGroup().id)}')

@description('Initial container tag to configure on the Web App. Pipeline will update to commit SHA during deploy.')
param webAppImageTag string = 'latest'

@description('Log Analytics workspace name.')
param logAnalyticsName string = '${namePrefix}-${env}-law'

@description('Application Insights component name.')
param appInsightsName string = '${namePrefix}-${env}-appi'

@description('Microsoft Foundry resource name (multi-service Cognitive Services resource).')
param foundryName string = '${namePrefix}-${env}-foundry'

@description('SKU for Microsoft Foundry (e.g. S0).')
param foundrySku string = 'S0'

module acr './modules/acr.bicep' = {
  name: 'acr'
  params: {
    name: acrName
    location: location
    sku: acrSku
    tags: tags
  }
}

module appServicePlan './modules/appservice-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: appServicePlanName
    location: location
    sku: appServicePlanSku
    tags: tags
  }
}

module appInsights './modules/appinsights.bicep' = {
  name: 'appInsights'
  params: {
    workspaceName: logAnalyticsName
    appInsightsName: appInsightsName
    location: location
    tags: tags
  }
}

module webApp './modules/webapp.bicep' = {
  name: 'webApp'
  params: {
    name: webAppName
    location: location
    planId: appServicePlan.outputs.id
    acrLoginServer: acr.outputs.loginServer
    imageName: '${acr.outputs.loginServer}/zavastore:${webAppImageTag}'
    appInsightsConnectionString: appInsights.outputs.connectionString
    tags: tags
  }
}

// Needed to scope role assignment directly to the registry resource
resource acrRegistry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' existing = {
  name: acrName
}

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // role assignment name must be deploy-time calculable; use deterministic values only
  name: guid(acrRegistry.id, webAppName, 'AcrPull')
  scope: acrRegistry
  properties: {
    principalId: webApp.outputs.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalType: 'ServicePrincipal'
  }
}

module foundry './modules/foundry.bicep' = {
  name: 'foundry'
  params: {
    name: foundryName
    location: location
    sku: foundrySku
    tags: tags
  }
}

output acrLoginServer string = acr.outputs.loginServer
output webAppHostName string = webApp.outputs.defaultHostName
output webAppPrincipalId string = webApp.outputs.principalId
output appInsightsConnectionString string = appInsights.outputs.connectionString
output foundryEndpoint string = foundry.outputs.endpoint

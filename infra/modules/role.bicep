@description('Principal ID to receive the role assignment (e.g. system-assigned managed identity).')
param principalId string

@description('Role definition ID (GUID). Default is AcrPull.')
param roleDefinitionId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

@description('Deterministic role assignment name (GUID).')
param roleAssignmentName string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}

output id string = roleAssignment.id

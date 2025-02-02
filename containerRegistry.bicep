// playground:https://bicepdemo.z22.web.core.windows.net/
param location string = resourceGroup().location
param containerVer string
param gitRepository string

// https://github.com/Azure-Samples/azure-data-factory-runtime-app-service/blob/ca44b7f23971c608a4e33020d130026a06f07788/deploy/modules/acr.bicep
@description('The name of the container registry to create. This must be globally unique.')
param containerRegistryName string = 'acr${uniqueString(resourceGroup().id)}'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

var containerImageTag = containerVer
var dockerfileSourceGitRepository = gitRepository
// https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries/taskruns
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-script-bicep
param guidValue string = newGuid()
resource buildTask 'Microsoft.ContainerRegistry/registries/taskRuns@2019-06-01-preview' = {
  parent: containerRegistry
  name: 'buildTask'
  properties: {
    forceUpdateTag: guidValue
    runRequest: {
      type: 'DockerBuildRequest'
      dockerFilePath: 'Dockerfile'
      sourceLocation: dockerfileSourceGitRepository
      imageNames: [
        'linebot/aca:${containerImageTag}'
      ]
      platform: {
        os: 'Linux'
        architecture: 'amd64'
      }
      isPushEnabled: true
    }
  }
}

output acrName string = containerRegistry.name

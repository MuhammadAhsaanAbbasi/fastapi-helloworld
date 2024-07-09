@description('Application Suffix that will applied to all resources')
param appSuffix string = uniqueString(resourceGroup().id)

@description('The Location to deploy all resources')
param location string = resourceGroup().location

@description('The name of the log Analytics workspace')
param logAnalyticsWorkspace string = 'log-analytics-${appSuffix}'

@description('The name of the Application Insights workspace')
param appInsightsWorkspace string = 'app-insights-${appSuffix}'

@description('The name of the Container App Environment')
param ContainerAppEnvironment string = 'container-app-environment${appSuffix}'

@description('The name of the Docker Image to Deploy')
param Image string

param ContainerAppName string = 'fastapi-serverless-${appSuffix}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspace
  location: location
  properties: {
    sku:{
      name: 'PerGB2018'
    }
  }
}

resource AppInsights 'Microsoft.insights/components@2020-02-02' = {
  name: appInsightsWorkspace
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource environment 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: ContainerAppEnvironment
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listkeys().primarySharedKey
      }
    }
  }
}

resource ContainerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: ContainerAppName
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8000
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      containers: [
        {
          name: ContainerAppName
          image: Image
          resources: {
            cpu: json('1.0')
            memory: '4Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 4
      }
    }
  }
}

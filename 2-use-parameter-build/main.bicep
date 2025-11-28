@description('The name of the environment. This must be dev, test, or prod.')
// dev, test, prodのみパラメーター値を許可する
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('The unique name of the solution. This id used to ensure that resource names are unique.')
// リソースの名前を5文字以上30文字以下にする
@minLength(5)
@maxLength(30)
param solutionName string = 'toyhr${uniqueString(resourceGroup().id)}'

@description('The number of App Service plan instances.')
// パラメータの範囲を1から10に制限する
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int = 1

@description('The name and tier of the App Service plan SKU.')
param appServicePlanSku object
// = {
//   name: 'F1'
//   tier: 'Free'
// }

@description('The Azure region into watch the resources should be deployed.')
param location string = 'eastus'

@secure()
@description('The administator login username for SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administator login password for SQL server.')
param sqlServerAdministratorPassword string

@description('The name add tier of the SQL database SKU.')
param sqlDatabaseSku object

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'
var sqlServerName = '${environmentName}-${solutionName}-sql'
var sqlDatabaseName = 'Employees'

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

// SQLサーバーとデータベースリソースを追加する
resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: sqlDatabaseSku.name
    tier: sqlDatabaseSku.tier
  }
}

// コマンド
// az deployment group create \
//   --name main \
//   --template-file main.bicep \
//   --parameters main.parameters.dev.json

// keyVaultName='YOUR-KEY-VAULT-NAME'
// read -s -p "Enter the login name: " login
// read -s -p "Enter the password: " password

// az keyvault create --name $keyVaultName --location eastus --enabled-for-template-deployment true
// az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorLogin" --value $login --output none
// az keyvault secret set --vault-name $keyVaultName --name "sqlServerAdministratorPassword" --value $password --output none

// az keyvault show --name $keyVaultName --query id --output tsv
// 例: /subscriptions/aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e/resourceGroups/PlatformResources/providers/Microsoft.KeyVault/vaults/toysecrets

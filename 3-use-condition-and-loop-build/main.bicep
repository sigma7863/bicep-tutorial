// コピー ループを使用して複数のインスタンスをデプロイする
@description('The Azure regions into witch the resources should be deployed')
param locations array = [
  'westus'
  'eastus2'
  'eastasia' // ティディベアおもちゃをアジアで販売するために東アジアリージョンも追加
]

// 仮想ネットワークを Bicep ファイルに追加する
@description('The IP address range for all virtual network to use.')
param virtualNetworkAddressPrefix string = '10.10.0.0/16'

@description('The name and IP address range for each submit in the virtual networks.')
param subnets array = [
  {
    name: 'frontend'
    ipAddressRange: '10.10.5.0/24'
  }
  {
    neme: 'backend'
    ipAddressRange: '10.10.10.0/24'
  }
]

var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }
}
]

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorLoginPassword string

module databases 'modules/database.bicep' = [for location in locations: {
  params: {
    location: location
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorPassword: sqlServerAdministratorLoginPassword
  }
}] 

resource virtualNetworks 'Microsoft.Network/virtualNetwork@2024-05-01' = [for location in locations: {
  name: 'teddybear-${location}'
  location: location
  properties:{
    addressSpace:{
      adressPrefixes:[
        virtualNetworkAddressPrefix
      ]
    }
    subnets: subnetProperties
  }
}]

// 親 Bicep ファイルを通して出力を渡す
output serverInfo array = [for i in range(0, length(locations)): {
  name: databases[i].outputs.serverName
  location: databases[i].outputs.location
  fullyQualifiedDomainName: databases[i].outputs.serverFullyQualifiedDomainName
}]

// あなたの玩具会社は、複数の国と地域で新しいテディ ベアの玩具を発売しようと考えています。 コンプライアンス上の理由から、おもちゃを発売するすべての Azure リージョンにインフラストラクチャを分散させる必要があります。
// あなたは、複数の場所のさまざまな環境に、同じリソースをデプロイする必要がありました。 デプロイ パラメーターを変更することで、再利用してリソースのデプロイを制御できる柔軟な Bicep ファイルを作成したいと考えていました。
// 一部のリソースを特定の環境にのみデプロイするには、Bicep ファイルに条件を追加しました。 その後、コピー ループを使用して、さまざまな Azure リージョンにリソースをデプロイしました。 変数ループを使用して、デプロイするリソースのプロパティを定義しました。 最後に、出力ループを使用して、デプロイされたリソースのプロパティを取得しました。


resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: 'carrotcakeapclouds' // must be globally unique
    location: 'eastus'
    kind: 'Storage'
    sku: {
        name: 'Standard_LRS'
    }
}
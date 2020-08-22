//Variables
var location = 'eastus'

//Server Params
param serverName string = 'ap-server'
param adminLogin string = 'ap-login'
param adminPassword string = 'woeinfwprgerv34f'

//Server Declaration
resource sfarm 'Microsoft.Web/serverfarms@2018-02-01' = {
    name: serverName
    location: location
    properties: {
        name: hostingPlan
        workerSizeId: 1
        reserved: true
        numberOfWorkers: 1
    }
    sku: {
        Tier: 'Standard'
        Name: 'S1'
    }
    kind: 'linux'
}
//Website Params
param hostingPlan string = 'ap-hostingPlan'
param siteName string = 'ap-website'
param dbName string = 'ap-database'

//Website Declaration
resource site 'Microsoft.Web/sites@2018-11-01' = {
    name: siteName
    location: location
    properties: {
        siteConfig: {
            linuxFxVersion: 'php|7.0'
            connectionStrings: [
                {
                name: 'defaultConnection'
                ConnectionString: concat('Database=', dbName, ';Data Source=', reference(resourceId('Microsoft.DBforMySQL/servers', serverName)).fullyQualifiedDomainName, ';User Id=', adminLogin,'@',serverName, ';Password=',adminPassword)
                type: 'mysql'
                }
            ]
        }
        name: siteName
        serverFarmId: hostingPlan
    }
}

//MySQL DB Params
param dbsku string {
    default: 'GP_Gen5_2'
    allowedValues: [
        'GP_Gen5_2'
        'GP_Gen5_4'
        'GP_Gen5_8'
        'GP_Gen5_16'
        'GP_Gen5_32'
        'MO_Gen5_2'
        'MO_Gen5_4'
        'MO_Gen5_8'
        'MO_Gen5_16'
        'MO_Gen5_32'
    ]
    metadata: {
        description: 'Azure database for mySQL sku name'
    }
}
param dbtier string {
    default: 'GeneralPurpose'
    allowedValues: [
        'GeneralPurpose'
        'MemoryOptimized'
    ]
    metadata: {
        description: 'Azure database for mySQL pricing tier'
    }
}
param dbcapacity int {
    default: 2
    allowedValues: [
        2
        4
        8
        16
        32
    ]
}
param dbskusize int {
    default: 51200
    allowedValues: [
        102400
        51200
    ]
    metadata: {
        description: 'Azure database for mySQL SKU size'
    }
}
param dbskufam string = 'Gen5'
param mysqlVersion string = '5.6'
//MYSQL DB Declaration
resource mysqlServer 'Microsoft.DBforMySQL/servers@2017-12-01' = {
    name: serverName
    location: location
    sku: {
        name: dbsku
        tier: dbtier
        capacity: dbcapacity
        size: dbskusize
        family: dbskufam
    }
    properties: {
        version: mysqlVersion
        administratorLogin: adminLogin
        administratorLoginPassword: adminPassword
        storageProfile: {
            storageMB: dbskusize
            backupRetentionDays: 7
            geoRedundantBackup: 'Disabled'
        }
        sslEnforcement: 'Disabled'
    }
    resources: [ 
        {
            type: 'firwallrules'
            apiVersion: '2017-12-01'
            name: 'AllowAzureIPs'
            location: location
            properties: {
                startIpAddress: '0.0.0.0'
                endIpAddress: '0.0.0.0'
            }
        }
    ]
}

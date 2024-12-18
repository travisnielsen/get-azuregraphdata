# Network Analysis Scripts

This is a sample PowerShell script for exporting large amounts of data via Azure Resource Graph API. This can be useful for more complex analysis that needs to be done offline using exported data.

## Configuration

In the `scripts` folder, create a file named `config.json` and populate it with the following json data. For convenience, a sample file (`config.sample.json`) has been provided.

```json
{
    "tenantId": "",
    "subscriptionId": "",
    "outputPath": "output"
}
```

## Sample queries

Get all VNETs that are peered with other VNETs:

```code
$kqlQuery = "resources
| where type == ""microsoft.network/virtualnetworks""
| where array_length(properties[""virtualNetworkPeerings""]) > 0
| extend peeringCount = array_length(properties[""virtualNetworkPeerings""])
| project id, name, location, resourceGroup, subscriptionId, tags, peeringCount, properties"
```

Get all private endpoints

```code
$kqlQuery = "resources
| where type == "microsoft.network/privateendpoints"
| extend serviceConnections = parse_json(properties['privateLinkServiceConnections'])
| extend groupId = serviceConnections[0].properties.groupIds[0]
| extend privateLinkSvcId = serviceConnections[0].properties.privateLinkServiceId"
```

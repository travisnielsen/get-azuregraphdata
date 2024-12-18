$configFile = "config.json"
$contextInfo = Get-Content $configFile | ConvertFrom-Json

$tenantId = $contextInfo.tenantId
$subscriptionId = $contextInfo.subscriptionId
$outputPath = $contextInfo.outputPath

Connect-AzAccount -Tenant $tenantId -Subscription $subscriptionId

# Run these commands if you have multiple subscriptions
Get-AzSubScription
Set-AzContext -Subscription $subscriptionId

$kqlQuery = "resources
| where type == ""microsoft.network/virtualnetworks""
| extend peeringCount = array_length(properties[""virtualNetworkPeerings""])
| project id, name, location, resourceGroup, subscriptionId, tags, peeringCount, properties"

$batchSize = 500
$skipResult = 0

[System.Collections.Generic.List[string]]$kqlResult

while ($true) {

if ($skipResult -gt 0) {
    $graphResult = Search-AzGraph -Query $kqlQuery -First $batchSize -SkipToken $graphResult.SkipToken
  }
  else {
    $graphResult = Search-AzGraph -Query $kqlQuery -First $batchSize
  }

$kqlResult += $graphResult.data

if ($graphResult.data.Count -lt $batchSize) {
    break;
  }
  $skipResult += $skipResult + $batchSize
}

$kqlResult | Export-Csv -Path $outputPath -Append -NoTypeInformation
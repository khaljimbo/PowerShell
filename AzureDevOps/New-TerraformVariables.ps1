## Reads the Terraform Output into memory so it can be used in future pipeline tasks

Set-Location $(Pipeline.Workspace)
$data = terraform output -json | ConvertFrom-Json
Write-Host -ForegroundColor Yellow "Terraform output data successfully loaded to memory"

$resourceGroup = $data.resourceGroupName.value 
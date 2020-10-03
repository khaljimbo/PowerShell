function New-SqlMetrics {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)]
        [string]
        $sqlServer,

        [Parameter(Mandatory = $true)]
        [string]
        $sqlDatabase,

        [Parameter(Mandatory = $true)]
        [string]
        $sqlUser,

        [Parameter(Mandatory = $true)]
        [string]
        $metricName,

        [Parameter(Mandatory = $true)]
        [string]
        $metricValue,
        
        [Parameter(Mandatory = $true)]
        [string]
        $metricType,

        [Parameter(Mandatory = $true)]
        [string]
        $hostName,

        [Parameter(Mandatory = $true)]
        [string]
        $apiKey

    )
    
    begin {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $time = [int][double](Get-Date -UFormat %s)
        $header = @{
            "Content-Type" = "application/json"
        }

        # Details needed to get secret from Azure KeyVault
        $sqlPass = Get-AzKeyVaultSecret

        $sqlQuery = 
        $connString = "Server=$sqlServer;Initial Catalog=$sqlDatabase;persist security info=True;User ID=$sqlUser;Password=$sqlPass.Secret"
    }
    
    process {

        # Get the SQL Data
        try {            
            $sqlCmd = Invoke-SqlCmd -ConnectionString $connString -Query $sqlQuery
        }
        catch {
            Write-Error $_.ErrorDetails
        }

        # Send the data to Datadog
        try {
            $request = Invoke-WebRequest `
            -Uri "https://api.datadoghq.com/api/v1/series?api_key=$apiKey" -UseBasicParsing `
            -Headers $header
            -body "{
                `"series`": [{
                    `"metric`": `"$metricName`",
                    `"points`": [[$time, $metricValue]],
                    `"type`": `"$metricType`",
                    `"host`": `"$hostName`"
                }]
            }" `
            -Method Post
        }
        catch {
            $scriptError = $_ -split "/n"
            if ($scriptError.Count) {
                $scriptError | ForEach-Object {Write-Error $_}
            }
            else {
            Write-Error $scriptError
            }
        }
    }
        
    end {
        
    }
}

New-SqlMetrics `
-sqlServer `
-sqlDatabase `
-sqlUser `
-metricName "SQL Server Data" `
-metricValue $sqlCmd `
-metricType `
-hostName `
-apiKey `
-Verbose 
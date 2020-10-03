function New-AzureDevOpsVariable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [string]
        $Value
    )
    
    process {
        $variable = "##vso[task.setvariable variable=$name]$value"
        Write-Host $variable
    }
    
}
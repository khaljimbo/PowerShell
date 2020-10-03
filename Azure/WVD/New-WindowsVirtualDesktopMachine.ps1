function new-WVDMachine {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $AADTenantID,

        [Parameter(Mandatory = $true)]
        [string]
        $HostPoolName,

        [Parameter(Mandatory = $true)]
        [string]
        $AppGroupName,

        [Parameter(Mandatory = $true)]
        [string]
        $AppID,

        [Parameter(Mandatory = $true)]
        [securestring]
        $Password,
        
        [Parameter(Mandatory = $true)]
        [string]
        $TokenPath, 

        [Parameter(Mandatory = $true)]
        [string]
        $ExpirantionHours
    )
    
    begin {

        #Requires -PSEdition Desktop

        Write-Host "Checking if WVD Management Module is installed"
        if (!(Get-Module -Name "Microsoft.RDInfra.RDPowerShell")) {
            Write-Host "WVD Management Module is not installed. Proceeding to install" {
                try {
                    Install-Module Microsoft.RDInfra.RDPowerShell
                }
                catch {
                    Write-Host "Install of Module failed"
                    Write-Error $_.ErrorDetails
                }
            }            
        }

        Write-Host "Begining Setup of WVD"

        Write-Host "Authenticating to WVD against Azure AD"
        try {
            # Gets the credentials of the service principal
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AppID, $Password
            # Logs into the RDS Account with the service principal details supplied above
            Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" -ServicePrincipal -AadTenantId $AADTenantID
            Write-Host "Successfully authenticated to WVD against Azure AD"
        }
        catch {
            Write-Host "Unable to Authenticate to WVD against Azure AD"
            Write-Error $_.ErrorDetails
        }

        # Creates a token to be able to add a VM to the WVD RDS Pool
        Write-Host "Creating RDS Registration Info"
        try {
            New-RdsRegistrationInfo -TenantName $AADTenantID -HostPoolName $HostPoolName -ExpirationHours $ExpirantionHours | Select-Object -ExpandProperty Token | Out-File -FilePath $TokenPath
            Write-Host "Successfully created RDS Regestration Info"
        }
        catch {
            Write-Host "Unable to create RDS Registration info"
            Write-Error $_.ErrorDetails
        }

        # Export the Token to join the VM to WVD RDS
        Write-Host "Exporting RDS Registration Token"
        try {
            $token = (Export-RdsRegistrationInfo -TenantName $AADTenantID -HostPoolName $HostPoolName).Token
            Write-Host "Successfully exported RDS Registration Token"
        }
        catch {
            Write-Host "Unable to export RDS Registration Token"
            Write-Error $_.ErrorDetails
        }

        # Download the WVD installer file
        Write-Host "Downloading WVD Installer file"
        $url = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
        $path = "C:\Temp\WVDInstaller.msi"
        try {
            
            if(!(Get-Item -ItemType Directory -Path "C:\Temp")) {
                New-Item -ItemType Directory -Path "C:\Temp" 
            }
            
            if(!(Get-Item -ItemType file -Path $path)) {
                (New-Object System.Net.WebClient).DownloadFile($url, $path)
            }
          
            Write-Host "Successfully downloaded installer file"
        }
        catch {
            Write-Host "Unable to download installer file"
            Write-Error $_.ErrorDetails -Verbose
        }
    }
    
    process {

    }
    end {
        
    }
}
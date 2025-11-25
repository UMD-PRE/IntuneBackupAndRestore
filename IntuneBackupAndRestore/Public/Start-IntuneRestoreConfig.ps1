function Start-IntuneRestoreConfig() {
    <#
    .SYNOPSIS
    Restore Intune Configuration
    
    .DESCRIPTION
    Restore Intune Configuration
    
    .PARAMETER Path
    Path where backup (JSON) files are located.
    
    .EXAMPLE
    Start-IntuneRestore -Path C:\temp
    
    .NOTES
    Requires the MSGraph SDK PowerShell Module

    Connect to MSGraph first, using the 'Connect-MgGraph' cmdlet.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    [PSCustomObject]@{
        "Action" = "Restore"
        "Type"   = "Intune Backup and Restore Action"
        "Name"   = "IntuneBackupAndRestore - Start Intune Restore Config"
        "Path"   = $Path
    }

    #Connect to MS-Graph if required
    if ($null -eq (Get-MgContext)) {
        connect-mggraph -scopes "DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, DeviceManagementScripts.ReadWrite.All" 
    }else{
        Write-Host "MS-Graph already connected, checking scopes"
        $scopes = Get-MgContext | Select-Object -ExpandProperty Scopes
        $requiredScopes = @(
            "DeviceManagementApps.ReadWrite.All",
            "DeviceManagementConfiguration.ReadWrite.All",
            "DeviceManagementServiceConfig.ReadWrite.All",
            "DeviceManagementManagedDevices.ReadWrite.All"
        )
        # Use case-insensitive comparison
        $missingScopes = $requiredScopes | Where-Object {
            $requiredScope = $_
            -not ($scopes | Where-Object { $_ -eq $requiredScope })
        }

        if ($missingScopes) {
            Write-Error "Missing required permission scopes: $($missingScopes -join ', ')"
            Write-Error "Please reconnect with the correct permissions using: Connect-MgGraph -Scopes 'DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All'"
            throw "Insufficient permissions. Restore cannot continue."
        }else{
            Write-Host "MS-Graph scopes are correct"
        }

    }

    Invoke-IntuneRestoreAutopilotDeploymentProfile -Path $Path -ErrorAction Continue
    Invoke-IntuneRestoreConfigurationPolicy -Path $Path -ErrorAction Continue
    Invoke-IntuneRestoreDeviceCompliancePolicy -Path $Path -ErrorAction Continue
    Invoke-IntuneRestoreDeviceConfiguration -Path $Path -ErrorAction Continue
    Invoke-IntuneRestoreDeviceHealthScript -Path $Path -ErrorAction Continue
    Invoke-IntuneRestoreDeviceManagementScript -Path $Path -ErrorAction Continue
    Invoke-IntuneRestoreGroupPolicyConfiguration -Path $Path -ErrorAction Continue
    Invoke-IntuneRestoreDeviceManagementIntent -Path $Path -ErrorAction Continue
    Invoke-IntuneRestoreAppProtectionPolicy -Path $Path -ErrorAction Continue
}

function Start-IntuneBackup() {
    <#
    .SYNOPSIS
    Backup Intune Configuration

    .DESCRIPTION
    Backup Intune Configuration

    .PARAMETER Path
    Path to store backup (JSON) files.

    .EXAMPLE
    Start-IntuneBackup -Path C:\temp

    .NOTES
    Requires the MSGraph SDK PowerShell Module

    Connect to MSGraph first, using the 'Connect-MgGraph' cmdlet and the scopes: 'DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All'.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    [PSCustomObject]@{
        "Action" = "Backup"
        "Type"   = "Intune Backup and Restore Action"
        "Name"   = "IntuneBackupAndRestore - Start Intune Backup Config and Assignments"
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
            Write-Error "Please reconnect with the correct permissions using: Connect-MgGraph -Scopes 'DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All, DeviceManagementManagedDevices.ReadWrite.All, DeviceManagementScripts.ReadWrite.All'"
            throw "Insufficient permissions. Backup cannot continue."
        }else{
            Write-Host "MS-Graph scopes are correct"
        }
		Write-Host ""
    }

    Invoke-IntuneBackupAutopilotDeploymentProfile -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupAutopilotDeploymentProfileAssignment -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupClientApp -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupClientAppAssignment -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupConfigurationPolicy -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupConfigurationPolicyAssignment -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupDeviceCompliancePolicy -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupDeviceCompliancePolicyAssignment -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupDeviceConfiguration -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupDeviceConfigurationAssignment -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupDeviceHealthScript -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupDeviceHealthScriptAssignment -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupDeviceManagementScript -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupDeviceManagementScriptAssignment -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupGroupPolicyConfiguration -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupGroupPolicyConfigurationAssignment -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupDeviceManagementIntent -Path $Path -ErrorAction Continue
    Invoke-IntuneBackupAppProtectionPolicy -Path $Path -ErrorAction Continue
}

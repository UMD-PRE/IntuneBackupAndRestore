# Intune Backup & Restore

![PowerShell Gallery](https://img.shields.io/powershellgallery/v/IntuneBackupAndRestore.svg?label=PSGallery%20Version&logo=PowerShell&style=flat-square)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IntuneBackupAndRestore.svg?label=PSGallery%20Downloads&logo=PowerShell&style=flat-square)

This PowerShell Module queries Microsoft Graph, and allows for cross-tenant Backup & Restore actions of your Intune Configuration.

Intune Configuration is backed up as (json) files in a given directory.

## Credits
Thanks https://github.com/mhu4711 for updating this PowerShell module to the Microsoft.Graph PowerShell module.

## Installing IntuneBackupAndRestore

```powershell
# Install IntuneBackupAndRestore from the PowerShell Gallery
Install-Module -Name IntuneBackupAndRestore
```

## Updating IntuneBackupAndRestore

```powershell
# Update IntuneBackupAndRestore from the PowerShell Gallery
Update-Module -Name IntuneBackupAndRestore
```

## Prerequisites

### Required PowerShell Modules
- [Microsoft.Graph](https://github.com/microsoftgraph/msgraph-sdk-powershell) PowerShell Module
  ```powershell
  Install-Module -Name Microsoft.Graph
  Install-Module -Name Microsoft.Graph.Beta -AllowClobber
  ```
- Make sure to import the IntuneBackupAndRestore PowerShell module before using it:
  ```powershell
  Import-Module IntuneBackupAndRestore
  ```

### Required Permissions

**For Interactive Use (Delegated Permissions):**
When running backups and restores interactively, connect with the following Microsoft Graph API scopes:

```powershell
Connect-MgGraph -Scopes @(
    'DeviceManagementApps.ReadWrite.All',
    'DeviceManagementConfiguration.ReadWrite.All',
    'DeviceManagementServiceConfig.ReadWrite.All',
    'DeviceManagementManagedDevices.ReadWrite.All'
)
```

**⚠️ Important - New Permission Requirement:**
Starting **July 31, 2025**, Microsoft requires the `DeviceManagementScripts.ReadWrite.All` permission for backing up and restoring:
- Device Management Scripts (PowerShell Scripts)
- Device Health Scripts (Proactive Remediations)

To prepare for this change, add this scope when connecting:
```powershell
Connect-MgGraph -Scopes @(
    'DeviceManagementApps.ReadWrite.All',
    'DeviceManagementConfiguration.ReadWrite.All',
    'DeviceManagementServiceConfig.ReadWrite.All',
    'DeviceManagementManagedDevices.ReadWrite.All',
    'DeviceManagementScripts.ReadWrite.All'  # Required from July 2025
)
```

**For Application/Service Principal Use:**
If running backups via automation or service principals, ensure your Azure AD App Registration has these Application permissions:
- `DeviceManagementApps.ReadWrite.All`
- `DeviceManagementConfiguration.ReadWrite.All`
- `DeviceManagementServiceConfig.ReadWrite.All`
- `DeviceManagementManagedDevices.ReadWrite.All`
- `DeviceManagementScripts.ReadWrite.All` (required from July 2025)

### Intune Administrator Role
The account or service principal used must have at least **Intune Administrator** role assigned in Entra ID (Azure AD).

## Features

### Backup actions
- Administrative Templates (Device Configurations)
- Administrative Template Assignments
- App Protection Policies
- App Protection Policy Assignments
- Autopilot Deployment Profiles
- Autopilot Deployment Profile Assignments
- Client Apps
- Client App Assignments
- Device Compliance Policies
- Device Compliance Policy Assignments
- Device Configurations
- Device Configuration Assignments
- Device Management Scripts (Device Configuration -> PowerShell Scripts)
- Device Management Script Assignments
- Proactive Remediations
- Proactive Remediation Assignments
- Settings Catalog Policies
- Settings Catalog Policy Assignments
- Software Update Rings
- Software Update Ring Assignments
- Endpoint Security Configurations
  - Security Baselines
    - Windows 10 Security Baselines
    - Microsoft Defender ATP Baselines
    - Microsoft Edge Baseline
  - Antivirus
  - Disk encryption
  - Firewall
  - Endpoint detection and response
  - Attack surface reduction
  - Account protection
  - Device compliance

### Restore actions
- Administrative Templates (Device Configurations)
- Administrative Template Assignments
- App Protection Policies
- App Protection Policy Assignments
- Autopilot Deployment Profiles
- Autopilot Deployment Profile Assignments
- Client App Assignments
- Device Compliance Policies
- Device Compliance Policy Assignments
- Device Configurations
- Device Configuration Assignments
- Device Management Scripts (Device Configuration -> PowerShell Scripts)
- Device Management Script Assignments
- Proactive Remediations
- Proactive Remediation Assignments
- Settings Catalog Policies
- Settings Catalog Policy Assignments
- Software Update Rings
- Software Update Ring Assignments
- Endpoint Security Configurations
  - Security Baselines
    - Windows 10 Security Baselines
    - Microsoft Defender ATP Baselines
    - Microsoft Edge Baseline
  - Antivirus
  - Disk encryption
  - Firewall
  - Endpoint detection and response
  - Attack surface reduction
  - Account protection
  - Device compliance

> Please note that some Client App settings can be backed up, for instance the retrieval of Win32 (un)install cmdlets, requirements, etcetera. The Client App itself is not backed up and this module does not support restoring Client Apps at this time.

## Examples

### Example 01 - Full Intune Backup

**Quick Start:**
```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes 'DeviceManagementApps.ReadWrite.All', 'DeviceManagementConfiguration.ReadWrite.All', 'DeviceManagementServiceConfig.ReadWrite.All', 'DeviceManagementManagedDevices.ReadWrite.All'

# Run full backup
Start-IntuneBackup -Path C:\temp\IntuneBackup
```

**What gets backed up:**
- All Intune configurations (Device Configurations, Compliance Policies, Administrative Templates, etc.)
- All assignments for each configuration
- Files are saved as JSON in organized folders by policy type

### Example 02 - Full Intune Restore

**Two-Step Restore Process:**
```powershell
# Step 1: Restore all configurations (creates new policies with new IDs)
Start-IntuneRestoreConfig -Path C:\temp\IntuneBackup

# Step 2: Restore all assignments to the newly created policies
Start-IntuneRestoreAssignments -Path C:\temp\IntuneBackup
```

**Why two steps?**
Separating configuration restore from assignment restore allows you to:
1. Review restored configurations before applying assignments
2. Restore configurations to a different tenant without assignments
3. Restore only assignments if configurations already exist

### Example 03 - Restore Intune Assignments 
If configurations have been restored:
```powershell
Start-IntuneRestoreAssignments -Path C:\temp\IntuneBackup
```

If reassigning assignments to existing (non-restored) configurations. In this case the assignments match the configuration id to restore to.  
This allows for restoring if display names have changed.
```powershell
Start-IntuneRestoreAssignments -Path C:\temp\IntuneBackup -RestoreById $true
```

### Example 04 - Restore only Intune Compliance Policies

```powershell
Invoke-IntuneRestoreDeviceCompliancePolicy -Path C:\temp\IntuneBackup
```

```powershell
Invoke-IntuneRestoreDeviceCompliancePolicyAssignment -Path C:\temp\IntuneBackup
```

### Example 05 - Restore Only Intune Device Configurations
```powershell
Invoke-IntuneRestoreDeviceConfiguration -Path C:\temp\IntuneBackup
```

```powershell
Invoke-IntuneRestoreDeviceConfigurationAssignment -Path C:\temp\IntuneBackup
```

### Example 06 - Backup Only Intune Endpoint Security Configurations
```powershell
Invoke-IntuneBackupDeviceManagementIntent -Path C:\temp\IntuneBackup
```

### Example 07 - Restore Only Intune Endpoint Security Configurations
```powershell
Invoke-IntuneRestoreDeviceManagementIntent -Path C:\temp\IntuneBackup
```

### Example 08 - Compare two Backup Files for changes
```powershell
# The DifferenceFilePath should point to the latest Intune Backup file, as it might contain new properties.
Compare-IntuneBackupFile -ReferenceFilePath 'C:\temp\IntuneBackup\Device Configurations\Windows - Endpoint Protection.json' -DifferenceFilePath 'C:\temp\IntuneBackupLatest\Device Configurations\Windows - Endpoint Protection.json'
```

### Example 09 - Compare all files in two Backup Directories for changes
```powershell
# The DifferenceFilePath should point to the latest Intune Backup file, as it might contain new properties.
Compare-IntuneBackupDirectories -ReferenceDirectory 'C:\temp\IntuneBackup' -DifferenceDirectory 'C:\temp\IntuneBackup2'
```

### Cross-Tenant Migration
This module is ideal for:
- **Tenant-to-Tenant Migrations:** Migrate configurations between Microsoft 365 tenants
- **Multi-Tenant Management:** Maintain consistent configurations across multiple tenants
- **Testing Environments:** Clone production configurations to test/dev tenants

## Performance Notes

- **Backup Time:** Depends on the number of policies (typical: 5-15 minutes for 1000+ policies)
- **Restore Time:** Slower than backup due to API rate limits (typical: 15-30 minutes for 1000+ policies)
- **Storage:** JSON files are human-readable and average 2-10 KB per policy

## Known Issues
- Does not support backing up Intune configuration items with duplicate Display Names. Files may be overwritten.
- Client Apps are backed up for reference but cannot be restored (app binaries/packages are not included)
- Some encrypted OMA settings in Device Configurations may require special permissions to decrypt during backup

## Version History

### Version 4.0.0
- Complete migration to Microsoft.Graph PowerShell SDK (from deprecated MSGraph module)
- Updated all API calls to use modern Graph SDK cmdlets
- Improved error handling and resilience

## Additional Resources

- [Microsoft Graph API for Intune](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)
- [Microsoft Graph Permissions Reference](https://learn.microsoft.com/en-us/graph/permissions-reference)
- [Intune Documentation](https://learn.microsoft.com/en-us/mem/intune/)

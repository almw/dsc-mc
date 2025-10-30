$PSVersionTable # .PowerShell         7.5.4.0 or https://github.com/PowerShell/PowerShell/releases/download/v7.5.4/PowerShell-7.5.4-win-x64.msi
winget search Microsoft.PowerShell
# Install PowerShell using WinGet
winget install --id Microsoft.PowerShell --source winget

# Install the machine configuration DSC resource module from PowerShell Gallery
Install-Module -Name GuestConfiguration -Force

# Get a list of commands for the imported GuestConfiguration module
Get-Command -Module GuestConfiguration

# Install PSDesiredStateConfiguration version 2.0.7 (the stable release)
Install-Module -Name PSDesiredStateConfiguration -RequiredVersion 2.0.7  -Force
Import-Module -Name PSDesiredStateConfiguration

# Get a list of commands for the imported PSDesiredStateConfiguration module
Get-Command -Module PSDesiredStateConfiguration

# Author a configuration
Install-Module -Name PSDscResources -Force
Install-Module -Name PSDesiredStateConfiguration -Force


Configuration MyConfig {
    Import-DscResource -Name 'Environment' -ModuleName 'PSDscResources'
    # Import the module that contains the WindowsFeature resource
    Import-DscResource -ModuleName PSDscResources

    Environment MachineConfigurationExample {
        Name   = 'MC_ENV_EXAMPLE'
        Value  = 'This was set by machine configuration'
        Ensure = 'Present'
        Target = @('Process', 'Machine')
    }
     # Define the resource for installing a Windows feature.
        WindowsFeature WebServer {
            Ensure = "Present"
            Name = "Web-Server"
        }
}

MyConfig

Rename-Item -Path .\MyConfig\localhost.mof -NewName MyConfig.mof -PassThru -Force

# Create a package that will only audit compliance
$params = @{
    Name          = 'MyConfig'
    Configuration = './MyConfig/MyConfig.mof'
    Type          = 'Audit'
    Force         = $true
}
New-GuestConfigurationPackage @params


# Create a package that will audit and apply the configuration (Set)
$params = @{
    Name          = 'MyConfig'
    Configuration = './MyConfig/MyConfig.mof'
    Type          = 'AuditAndSet'
    Force         = $true
}
New-GuestConfigurationPackage @params

# Create a package that will audit the configuration at 180 minute intervals
$params = @{
    Name          = 'MyConfig'
    Configuration = './MyConfig/MyConfig.mof'
    Type          = 'Audit'
    Force         = $true
    FrequencyMinutes = 180
}
New-GuestConfigurationPackage @params


# Total size of the uncompressed package
Expand-Archive -Path .\MyConfig.zip -DestinationPath MyConfigZip
Get-ChildItem -Recurse -Path .\MyConfigZip | Measure-Object -Sum Length | ForEach-Object -Process {
        $Size = [math]::Round(($_.Sum / 1MB), 2); "$Size MB"
    }


# Test machine configuration package artifacts

# Get the current compliance results for the local machine
Get-GuestConfigurationPackageComplianceStatus -Path ./MyConfig.zip


# Test applying the configuration to local machine
Start-GuestConfigurationPackageRemediation -Path ./MyConfig.zip

# Publish custom machine configuration package artifacts

# Creates a new resource group, storage account, and container
$ResourceGroup = '<resource-group-name>'
$Location      = '<location-id>'
New-AzResourceGroup -Name $ResourceGroup -Location $Location

$newAccountParams = @{
    ResourceGroupname = $ResourceGroup
    Location          = $Location
    Name              = '<storage-account-name>'
    SkuName           = 'Standard_LRS'
}
$container = New-AzStorageAccount @newAccountParams |
    New-AzStorageContainer -Name machine-configuration -Permission Blob

$context = $container.Context

## Using an existing storage container,
$connectionString = @(
    'DefaultEndPointsProtocol=https'
    'AccountName=<storage-account-name>'
    'AccountKey=<storage-key-for-the-account>' # ends with '=='
) -join ';'
$context = New-AzStorageContext -ConnectionString $connectionString


## Add the configuration package to the storage account. This example uploads the zip file ./MyConfig.zip to the blob container machine-configuration.
$setParams = @{
    Container = 'machine-configuration'
    File      = './MyConfig.zip'
    Context   = $context
}
$blob = Set-AzStorageBlobContent @setParams
$contentUri = $blob.ICloudBlob.Uri.AbsoluteUri


## Shared access signature (SAS) token in the URL to ensure secure access to the package.
$startTime = Get-Date
$endTime   = $startTime.AddYears(3)

$tokenParams = @{
    StartTime  = $startTime
    ExpiryTime = $endTime
    Container  = 'machine-configuration'
    Blob       = 'MyConfig.zip'
    Permission = 'r'
    Context    = $context
    FullUri    = $true
}
$contentUri = New-AzStorageBlobSASToken @tokenParams


# secure access to custom machine configuration package

# Using a User Assigned Identity with "Storage Blob Data Reader" role 
# Using a SAS Token
$startTime = Get-Date
$endTime   = $startTime.AddYears(3)

$tokenParams = @{
    StartTime  = $startTime
    ExpiryTime = $endTime
    Container  = '<storage-account-container-name>'
    Blob       = '<configuration-blob-name>'
    Permission = 'r'
    Context    = '<storage-account-context>'
    FullUri    = $true
}

$contentUri = New-AzStorageBlobSASToken @tokenParams

# sign machine configuration packages
# Signature validation using a code signing certificate
./WindowsSignatureValidation.ps1
# Certificate requirements
# The machine configuration agent expects the certificate public key to be present in "Trusted Publishers" on Windows machines and in the path /usr/local/share/ca-certificates/gc on Linux machines.

# Export the public key from a signing certificate, to import to the machine.
$Cert = Get-ChildItem -Path Cert:\LocalMachine\My |
    Where-Object { $_.Subject-eq 'CN=<CN-of-your-signing-certificate>' } |
    Select-Object -First 1
$Cert | Export-Certificate -FilePath '<path-to-export-public-key-cer-file>' -Force

# Create custom machine configuration policy definitions
# Create and publish a machine configuration package artifact
$PolicyConfig      = @{
  PolicyId      = '_My GUID_'
  ContentUri    = $contentUri
  DisplayName   = 'My audit policy'
  Description   = 'My audit policy'
  Path          = './policies/auditIfNotExists.json'
  Platform      = 'Windows'
  PolicyVersion = 1.0.0
}

New-GuestConfigurationPolicy @PolicyConfig

# Create a policy definition that enforces a custom configuration package,
$PolicyConfig2      = @{
  PolicyId      = '_My GUID_'
  ContentUri    = $contentUri
  DisplayName   = 'My deployment policy'
  Description   = 'My deployment policy'
  Path          = './policies/deployIfNotExists.json'
  Platform      = 'Windows'
  PolicyVersion = 1.0.0
  Mode          = 'ApplyAndAutoCorrect'
}

New-GuestConfigurationPolicy @PolicyConfig2

# Create a policy definition that audits using a custom configuration package
$PolicyConfig      = @{
  PolicyId      = '_My GUID_'
  ContentUri    = $contentUri
  DisplayName   = 'My audit policy'
  Description   = 'My audit policy'
  Path          = './policies/auditIfNotExists.json'
  Platform      = 'Windows'
  PolicyVersion = 1.0.0
}

New-GuestConfigurationPolicy @PolicyConfig

# Create a policy definition that enforces a custom configuration package
$PolicyConfig2      = @{
  PolicyId      = '_My GUID_'
  ContentUri    = $contentUri
  DisplayName   = 'My deployment policy'
  Description   = 'My deployment policy'
  Path          = './policies/deployIfNotExists.json'
  Platform      = 'Windows'
  PolicyVersion = 1.0.0
  Mode          = 'ApplyAndAutoCorrect'
}

New-GuestConfigurationPolicy @PolicyConfig2

# Create a policy definition that enforces a custom configuration package using a User-Assigned Managed Identity:
$PolicyConfig3      = @{
  PolicyId                  = '_My GUID_'
  ContentUri                = $contentUri
  DisplayName               = 'My deployment policy'
  Description               = 'My deployment policy'
  Path                      = './policies/deployIfNotExists.json'
  Platform                  = 'Windows'
  PolicyVersion             = 1.0.0
  Mode                      = 'ApplyAndAutoCorrect'
  LocalContentPath          = "C:\Local\Path\To\Package"      # Required parameter for managed identity
  ManagedIdentityResourceId = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identityName}" # Required parameter for managed identity
}

New-GuestConfigurationPolicy @PolicyConfig3 -ExcludeArcMachines

# Create a policy definition that enforces a custom configuration package using a System-Assigned Managed Identity:
$PolicyConfig4      = @{
  PolicyId                  = '_My GUID_'
  ContentUri                = $contentUri
  DisplayName               = 'My deployment policy'
  Description               = 'My deployment policy'
  Path                      = './policies/deployIfNotExists.json'
  Platform                  = 'Windows'
  PolicyVersion             = 1.0.0
  Mode                      = 'ApplyAndAutoCorrect'
  LocalContentPath          = "C:\Local\Path\To\Package"      # Required parameter for managed identity
}
New-GuestConfigurationPolicy @PolicyConfig4 -UseSystemAssignedIdentity

# Ref. https://learn.microsoft.com/en-us/azure/governance/machine-configuration/how-to/create-policy-definition
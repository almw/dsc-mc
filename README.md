# dsc-mc

Windows machine configuration automation using PowerShell DSC and Machine Configuration packages.

---

## Overview

`dsc-mc` provides a repeatable and version-controlled approach for configuring Windows systems using PowerShell Desired State Configuration (DSC).

The repository is designed to help automate:

* Windows machine provisioning
* Configuration deployment
* Machine Configuration package creation
* Signature validation workflows
* Local development environment setup

This project follows infrastructure-as-code principles to ensure systems remain consistent, auditable, and reproducible. PowerShell DSC is Microsoft's configuration management platform for declarative system management. ([GitHub][1])

---

## Features

* PowerShell DSC-based configuration management
* Reusable machine configuration packages
* Windows configuration automation
* Signature validation tooling
* Git environment bootstrap support
* Repeatable deployment workflows
* Infrastructure-as-code friendly structure

---

## Repository Structure

```text
.
├── MyConfig/                         # Compiled DSC configuration artifacts
├── MyConfigZip/                      # Packaged configuration output
├── MyConfig.ps1                      # Primary DSC configuration
├── MachineConfigurationPackage.ps1   # Package creation script
├── WindowsSignatureValidation.ps1    # Signature validation utilities
├── git.ps1                           # Git setup/bootstrap script
└── README.md
```

---

## Requirements

Before using this repository, ensure the following are installed:

* Windows 10/11 or Windows Server
* PowerShell 5.1+ or PowerShell 7+
* Administrator privileges
* PowerShell DSC enabled
* Git (recommended)

Verify your PowerShell version:

```powershell
$PSVersionTable.PSVersion
```

---

## Quick Start

### Clone the Repository

```bash
git clone https://github.com/almw/dsc-mc.git
cd dsc-mc
```

### Run the Main Configuration

```powershell
.\MyConfig.ps1
```

### Build Machine Configuration Package

```powershell
.\MachineConfigurationPackage.ps1
```

### Validate Windows Signatures

```powershell
.\WindowsSignatureValidation.ps1
```

---

## Workflow

```text
MyConfig.ps1
    ↓
Compile DSC Configuration
    ↓
Generate Machine Configuration Package
    ↓
Validate Signatures
    ↓
Deploy / Apply Configuration
```

---

## Usage

### Apply DSC Configuration

```powershell
Start-DscConfiguration -Path .\MyConfig -Wait -Verbose -Force
```

### Test Configuration Compliance

```powershell
Test-DscConfiguration
```

### View Current Configuration Status

```powershell
Get-DscConfigurationStatus
```

---

## Customization

You can customize machine behavior by editing:

* `MyConfig.ps1`
* Resources inside `MyConfig/`
* Packaging logic in `MachineConfigurationPackage.ps1`

Common customization scenarios:

* Developer workstation setup
* Windows feature enablement
* Security baseline configuration
* Environment variable management
* Git configuration
* Tool and package installation

---

## Security

* Validate signed scripts before execution
* Only run configurations from trusted sources
* Avoid committing credentials or secrets
* Review DSC resources before deployment
* Use least-privilege principles where possible

---

## Troubleshooting

### Enable Script Execution

```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process
```

### Restart WinRM

```powershell
Restart-Service WinRM
```

### List Installed DSC Resources

```powershell
Get-DscResource
```

### Check DSC Status

```powershell
Get-DscConfigurationStatus
```

---

## Use Cases

This repository can be used for:

* Developer workstation bootstrap
* Windows VM provisioning
* Lab environment setup
* Compliance validation
* Infrastructure configuration testing
* Repeatable local environment deployment

---

## Future Improvements

Potential roadmap ideas:

* CI/CD integration
* Azure Machine Configuration support
* Winget or Chocolatey package integration
* Logging and telemetry improvements
* Compliance reporting
* Multi-environment configuration support

---

## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Submit a pull request

---

## References

* [PowerShell DSC](https://github.com/PowerShell/DSC?utm_source=chatgpt.com)
* [DSC Community](https://github.com/dsccommunity?utm_source=chatgpt.com)
* [PowerShell GitHub Organization](https://github.com/powershell?utm_source=chatgpt.com)

---

## License

Add your preferred license here.

Example:

```text
MIT License
```

---

## Author

Maintained by [almw on GitHub](https://github.com/almw?utm_source=chatgpt.com)

Repository: [dsc-mc](https://github.com/almw/dsc-mc?utm_source=chatgpt.com)

[1]: https://github.com/PowerShell/DSC?utm_source=chatgpt.com "GitHub - PowerShell/DSC: This repo is for the DSC v3 project"

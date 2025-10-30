Configuration MyConfig {
    # Import the module that contains the WindowsFeature resource
    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -Name 'Environment' -ModuleName 'PSDscResources'
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
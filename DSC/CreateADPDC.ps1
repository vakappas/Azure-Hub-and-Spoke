configuration CreateADPDC 
{ 
   param 
   ( 
        [Parameter(Mandatory)]
        [string] $NodeName,

        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    ) 
    
    Import-DscResource -ModuleName xActiveDirectory, xStorage, xNetworking, PSDesiredStateConfiguration, xPendingReboot

    Node $NodeName
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
            ActionAfterReboot = 'ContinueConfiguration'
            AllowModuleOverwrite = $true
        }
 
        WindowsFeature DNS_RSAT
        { 
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
        }
 
        WindowsFeature ADDS_Install 
        { 
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        } 
 
        WindowsFeature RSAT_AD_AdminCenter 
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-AdminCenter'
        }
 
        WindowsFeature RSAT_ADDS 
        {
            Ensure = 'Present'
            Name   = 'RSAT-ADDS'
        }
 
        WindowsFeature RSAT_AD_PowerShell 
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-PowerShell'
        }
 
        WindowsFeature RSAT_AD_Tools 
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-Tools'
        }
 
        WindowsFeature RSAT_Role_Tools 
        {
            Ensure = 'Present'
            Name   = 'RSAT-Role-Tools'
        }      
 
        WindowsFeature RSAT_GPMC 
        {
            Ensure = 'Present'
            Name   = 'GPMC'
        }

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDS_Install"
        }

        xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec =$RetryIntervalSec
            RetryCount = $RetryCount
        }

        xDisk ADDataDisk {
            DiskNumber = 2
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk2"
        }       
         
        xADDomain FirstDS 
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $Admincreds
            SafemodeAdministratorPassword = $Admincreds
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
	        DependsOn = @("[xDisk]ADDataDisk", "[WindowsFeature]ADDS_Install")
        } 

   }
} 
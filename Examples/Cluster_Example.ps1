#requires -Version 4

$InstallerServiceAccount = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('DOMAIN\Administrator', (ConvertTo-SecureString -String 'Password01!' -AsPlainText -Force))


Configuration Cluster_Example
{
    Import-DscResource -Module cFailoverCluster        
              
    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            DebugMode = 'All'
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
        }
        
        WindowsFeature 'FailoverClustering'
        {
            Ensure = 'Present'
            Name = 'Failover-Clustering'
            IncludeAllSubFeature = $true
        }

        WindowsFeature 'RSATClusteringPowerShell'
        {
            Ensure = 'Present'
            Name = 'RSAT-Clustering-PowerShell'
        }
    
        $PrimaryClusterNodeName = ($Node | Where-Object -FilterScript {$_.Clusternode -eq 'Primary'}).NodeName
        $AdditionalClusterNodeNames = ($Node | Where-Object -FilterScript {$_.Clusternode -eq 'Additional'}).NodeName

        if ($Node.ClusterNode -eq 'Primary')
        {
            cCluster 'SQLCluster1'
            {
                DependsOn = @(
                    '[WindowsFeature]FailoverClustering', 
                    '[WindowsFeature]RSATClusteringPowerShell'
                )
                Name = $Node.FailoverClusterNetworkName
                StaticIPAddress = $Node.FailoverClusterIPAddress
                DomainAdministratorCredential = $Node.InstallerServiceAccount
            }
            WaitForAll 'SQLCluster1'
            {
                ResourceName = '[cCluster]SQLCluster1'
                NodeName = $AdditionalClusterNodeNames
                RetryIntervalSec = 5
                RetryCount = 720
            }
        }

        else
        {
            WaitForAll 'SQLCluster1'
            {
                ResourceName = '[cCluster]SQLCluster1'
                NodeName = $PrimaryClusterNodeName
                RetryIntervalSec = 5
                RetryCount = 720
            }

            cWaitForCluster 'SQLCluster1'
            {
                DependsOn = '[WaitForAll]SQLCluster1'
                Name = $Node.FailoverClusterNetworkName
                RetryIntervalSec = 10
                RetryCount = 60
            }

            cCluster 'SQLCluster1'
            {
                DependsOn = @(
                    '[cWaitForCluster]SQLCluster1',
                    '[WindowsFeature]FailoverClustering', 
                    '[WindowsFeature]RSATClusteringPowerShell'
                )
                Name = $Node.FailoverClusterNetworkName
                StaticIPAddress = $Node.FailoverClusterIPAddress
                DomainAdministratorCredential = $Node.InstallerServiceAccount
            }
        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = '*'
            PSDscAllowPlainTextPassword = $true
            InstallerServiceAccount     = $InstallerServiceAccount
            FailoverClusterNetworkName  = 'CLUSTER'
            FailoverClusterIPAddress    = '192.168.10.30'
        }
        @{
            NodeName    = 'Node1'
            ClusterNode = 'Primary'
        }
        @{
            NodeName    = 'Node2'
            ClusterNode = 'Additional'
        }
        @{
            NodeName    = 'Node3'
            ClusterNode = 'Additional'
        }
    )
}

Cluster_Example -ConfigurationData $ConfigurationData -OutputPath 'C:\DSC\Staging\Cluster_Example'
# cFailoverCluster

The **cFailoverCluster** module contains resources for Windows Failover Clustering.

## Resources

###cCluster

*   **Name**: KEY - Name of the Windows Failover Cluster
*   **StaticIPAddress**: Required - Cluster IP Address
*   **DomainAdministratorCredential**: Required - Credentials used to create the ClusterObject and form the Cluster

###cWaitForCluster

*   **Name**: KEY - Name of the Windows Failover Cluster
*   **RetryIntervalSec**: Time (in seconds) to tests if the cluster is available
*   **RetryCount**: Maximum number of retries to check if the cluster is available

###cClusterPreferredOwner

*   **ClusterGroup**: KEY - Name of the Cluster Group
*   **ClusterName**: Required - Name of the Windows Failover Cluster
*   **Nodes**: Required - Clusternodes affected (that should be, or not be owners)
*   **ClusterResources**: Cluster Resources affected
*   **Ensure**: Values (Present, Absent)

## Versions

### 1.2.1.6

* Minor fixes applied to cClusterPreferredOwner and Example added

### 1.2.1.0

* Add **cClusterPreferredOwner** resource.

### 1.2.0.0

* Cloned repository from xFailoverCluster and applied customised properties
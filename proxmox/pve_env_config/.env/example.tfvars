# Endpoint opentofu will use to make changes via the API
pve_endpoint="https://pve-host-02.local.example.com:8006"

# Names of the nodes in the cluster. If using standalone nodes, then only add one here.
# To manage multiple single nodes, create separate tfvars or leave out nodes here provide it 
# as command line argument.
nodes = [
    "pve-host-01",
    "pve-host-02"
]

## Node DNS / Host file configuration

# Search domain each node will be configured to use.
dns_search_domain = "local.example.com"
# DNS servers each node will be configured to use.
dns_servers = [
    "192.168.0.2",
    "192.168.0.3"
]

# Only needed if custom host entries are desired. If set, make sure the existing entries
# from each node's host file are added or they will be removed.
# node_host_entries = {
#     "pve-host-01" = [
#         {
#             ip_address = "127.0.0.1"
#             hostnames = [ "localhost.localdomain", "localhost" ]
#         },
#         {
#             ip_address = "192.168.0.21"
#             hostnames = [ "pve-host-01.local.example.com", "pve-host-01" ]
#         },
#         {
#             ip_address = "::1"
#             hostnames = [ "ip6-localhost", "ip6-loopback" ]
#         },
#         {
#             ip_address = "fe00::0"
#             hostnames = [ "ip6-localnet" ]
#         },
#         {
#             ip_address = "ff00::0"
#             hostnames = [ "ip6-mcastprefix" ]
#         },
#         {
#             ip_address = "ff02::1"
#             hostnames = [ "ip6-allnodes" ]
#         },
#         {
#             ip_address = "ff02::2"
#             hostnames = [ "ip6-allrouters" ]
#         },
#         {
#             ip_address = "ff02::3"
#             hostnames = [ "ip6-allhosts" ]
#         }
#     ],
#     "pve-host-02" = [
#         {
#             ip_address = "127.0.0.1"
#             hostnames = [ "localhost.localdomain", "localhost" ]
#         },
#         {
#             ip_address = "192.168.0.22"
#             hostnames = [ "pve-host-02.local.example.com", "pve-host-02" ]
#         },
#         {
#             ip_address = "::1"
#             hostnames = [ "ip6-localhost", "ip6-loopback" ]
#         },
#         {
#             ip_address = "fe00::0"
#             hostnames = [ "ip6-localnet" ]
#         },
#         {
#             ip_address = "ff00::0"
#             hostnames = [ "ip6-mcastprefix" ]
#         },
#         {
#             ip_address = "ff02::1"
#             hostnames = [ "ip6-allnodes" ]
#         },
#         {
#             ip_address = "ff02::2"
#             hostnames = [ "ip6-allrouters" ]
#         },
#         {
#             ip_address = "ff02::3"
#             hostnames = [ "ip6-allhosts" ]
#         }
#     ]
# }

## Custom RBAC, roles, pools, etc. All Optional

# Pools to group a set of virtual machines and datastores. Not required.
pools = [
    {
        pool_id = "automation"
    },
    {
        pool_id = "media"
    }
]

# Custom roles
roles = [
    {
        role_id = "ClusterAuditor"
        privileges = [ 
            "Mapping.Audit",
            "Pool.Audit",
            "SDN.Audit",
            "Sys.Audit",
            "VM.Audit",
            "VM.GuestAgent.Audit",
            "Datastore.Audit"
        ]
    },
    {
        role_id = "k8sCCM"
        privileges = [ 
            "Sys.Audit",
            "VM.Audit",
            "VM.GuestAgent.Audit"
        ]
    },
    {
        role_id = "k8sCSI"
        privileges = [ 
            "Sys.Audit",
            "VM.Audit",
            "VM.Allocate", 
            "VM.Clone",
            "VM.Config.CPU",
            "VM.Config.Disk",
            "VM.Config.HWType",
            "VM.Config.Memory",
            "VM.Config.Options",
            "VM.Migrate",
            "VM.PowerMgmt",
            "Datastore.Allocate",
            "Datastore.AllocateSpace",
            "Datastore.Audit"
        ]
    }
]

# Custom groups and optional role assignments
groups = [
    {
        group_id = "ClusterMonitors"
        acls = [{
            path = "/"
            role_id = "ClusterAuditor"
        }]
        comment = "Members of this group have access to monitor the cluster."
    },
    {
        group_id = "ClusterAdministrators"
        comment = "Administrators group where roles are assigned per user."
    }
]

# Users, optional group memberships and role assignments
users = [
    {
        user_id = "clustermonitorsvc"
        email = "clustermonitoring@example.com"
        first_name = "Cluster"
        first_name = "Monitoring"
        groups = ["ClusterMonitors"]
        comment = "Service account for monitoring the cluster."
    },
    {
        user_id = "johnadmin"
        email = "jadmin@example.com"
        first_name = "John"
        first_name = "Admin"
        groups = ["ClusterAdministrators"]
        acls = [{
            path = "/"
            role_id = "Administrator"  # Builtin role
        }]
        comment = "Service account for monitoring the cluster."
    }
]

# Example only. Use -var argument or create a tfvar file as part of your CI/CD, but don't
# commit passwords to your repository.
# Passwords are set only on initial user creation. They will never be updated by this script.
## Bash Example: 
## $ tofu apply -var-file .env/example.tfvars -var -var user_passwords='{"clustermonitorsvc"="secure@pass_word2"}'
user_passwords = {
    clustermonitorsvc = "secure@pass_word1>"
    # johnadmin not provided so will have password generated
}
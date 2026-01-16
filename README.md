# Mesh network with FRR in netns

This is a quick proof of concept to run FRR in multiple netns.  
Nodes are connected using veth which are attached to the appropriate netns.

## Setup host

Using Ubuntu 24.04 as base, run `./setup_host.sh` to install prerequisite
packages.  It disables FRR from running on the host itself to avoid 
confusion.

## Create mesh network

ASCII representation of a 5-node mesh with 5 FRR instances in their own namespace (ns):
```
          [ ns1 ]
         /  | |  \
      10.1.2.0/30  10.1.5.0/30
      /     | |     \
     /  10.1.3.0/30  \
    /       | |       \
 [ ns2 ]----+-+----[ ns5 ]
   |  \    /   \    /  |
   |   \  /     \  /   |
   |  10.2.4.0/30 10.3.5.0/30
   |     /       \     |
10.2.3.0/30     10.4.5.0/30
   |   /           \   |
   |  /             \  |
 [ ns3 ]-----------[ ns4 ]
         10.3.4.0/30
```

Run `./create_ns.sh` to set up the network namespaces and veth connections.
This creates a 5-node mesh network.

Configurations are placed at `/tmp/etc/frr/nsX`, for each X namespace.
This separates the namespace configs from collisions and cleans up when the 
host is rebooted.  Similarly, logs are at `/var/logs/frr/nsX` and runtime
variables (pid, etc) are at `/var/run/frr/nsX`.

## Connectivity Matrix (Subnet Map)

Here is the mapping of the links:

| From | To  | Subnet        | IP (.1)          | IP (.2)          |
|------|-----|---------------|------------------|------------------|
| ns1  | ns2 | 10.1.2.0/30   | ns1:veth1-2      | ns2:veth2-1      |
| ns1  | ns3 | 10.1.3.0/30   | ns1:veth1-3      | ns3:veth3-1      |
| ns1  | ns4 | 10.1.4.0/30   | ns1:veth1-4      | ns4:veth4-1      |
| ns1  | ns5 | 10.1.5.0/30   | ns1:veth1-5      | ns5:veth5-1      |
| ns2  | ns3 | 10.2.3.0/30   | ns2:veth2-3      | ns3:veth3-2      |
| ns2  | ns4 | 10.2.4.0/30   | ns2:veth2-4      | ns4:veth4-2      |
| ns2  | ns5 | 10.2.5.0/30   | ns2:veth2-5      | ns5:veth5-2      |
| ns3  | ns4 | 10.3.4.0/30   | ns3:veth3-4      | ns4:veth4-3      |
| ns3  | ns5 | 10.3.5.0/30   | ns3:veth3-5      | ns5:veth5-3      |
| ns4  | ns5 | 10.4.5.0/30   | ns4:veth4-5      | ns5:veth5-4      |



## Add FRR to namespaces

Run `./create_frr_ospf.sh` to add FRR and configurations to each namespace.  `./meshtest.sh` tests all points in the mesh.

# vsh
To access FRR in a namespace, run `./vsh` (or put it a usr/local/bin)
`vsh` is a wrapper around FRR's `vtysh`

- `vsh ns1` will put you into a vtysh inside netns ns1.
- `vsh ns1 -c "sho ip ro" -c "sho daemons"` (chained commands like vtysh)

# Mesh network with FRR in netns

This is a quick proof of concept to run FRR in multiple netns.  
Nodes are connected using veth which are attached to the appropriate netns.

## Setup host

Using Ubuntu 24.04 as base, run `./setup_host.sh` to install prerequisite
packages.  It disables FRR from running on the host itself to avoid 
confusion.

## Create mesh network

Run `./create_ns.sh` to set up the network namespaces and veth connections.
This creates a 5-node mesh network.

Configurations are placed at `/tmp/etc/frr/nsX`, for each X namespace.
This separates the namespace configs from collisions and cleans up when the 
host is rebooted.  Similarly, logs are at `/var/logs/frr/nsX` and runtime
variables (pid, etc) are at `/var/run/frr/nsX`.

## Add FRR to namespaces

Run `./create_frr_ospf.sh` to add FRR and configurations to each namespace.  `./meshtest.sh` tests all points in the mesh.

# vsh
To access FRR in a namespace, run `./vsh` (or put it a usr/local/bin)
`vsh` is a wrapper around FRR's `vtysh`

- `vsh ns1` will put you into a vtysh inside netns ns1.
- `vsh ns1 -c "sho ip ro" -c "sho daemons"` (chained commands like vtysh)
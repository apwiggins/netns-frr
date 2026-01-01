# Mesh network with FRR in netns

This is a quick proof of concept to run FRR in multiple netns.  
Nodes are connected using veth which are attached to the appropriate netns.

## setup host

Using Ubuntu 24.04 as base, run `./setup_host.sh`

## Create mesh network

Run `./create_ns.sh` to set up the network namespaces and veth connections.
This creates a 5-node mesh network.

## Add FRR to namespaces

Run `./create_frr_ospf.sh` to add FRR and configurations to each namespace.

To access FRR in a namespace, run `./vsh` (or put it a usr/local/bin)

- `vsh ns1` will put you into a vtysh inside netns ns1.
- `vsh ns1 -c "sho ip ro" -c "sho daemons"` (chained commands like vtysh)



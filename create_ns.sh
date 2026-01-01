#!/bin/bash

# Create five network namespaces (netns) and connect them
# with virtual Ethernet interfaces.

# Cleanup first (optional)
for i in {1..5}; do
  ip netns del ns$i 2>/dev/null || true
done

# Create network namespaces
for i in {1..5}; do
  sudo ip netns add ns$i
  sudo ip netns exec ns${i} link set lo up
  sudo ip netns exec ns${i} ip addr add 1.1.1.${i}/32 dev lo
done

# Connect namespaces with veth pairs
for i in {1..4}; do
  for j in $(seq $((i + 1)) 5); do
    sudo ip link add veth${i}-${j} type veth peer name veth${j}-${i}
    sudo ip link set veth${i}-${j} netns ns$i
    sudo ip link set veth${j}-${i} netns ns$j

    # Bring interfaces up and assign IPs
    sudo ip -n ns$i link set veth${i}-${j} up
    sudo ip -n ns$j link set veth${j}-${i} up

    sudo ip -n ns$i addr add 10.${i}.${j}.1/30 dev veth${i}-${j}
    sudo ip -n ns$j addr add 10.${i}.${j}.2/30 dev veth${j}-${i}
  done
done

for i in {1..5}; do
    sudo ip netns exec ns$i ip link set lo up
done
echo "==> Network namespaces and veth mesh created"

# Verify the network setup
printf "netns list: \n"
sudo ip netns ls

for i in {1..5}; do
  printf "ns$i: \n"
  sudo ip -br -n ns$i a show
done

# ip -br a show

printf "ping tests: \n"

printf "from ns1 --> ns2\n"
sudo ip netns exec ns1 ping -c 2 10.1.2.2

printf "from ns3 --> ns5\n"
sudo ip netns exec ns3 ping -c 2 10.3.5.2

printf "from ns5 --> ns4\n"
sudo ip netns exec ns5 ping -c 2 10.4.5.1

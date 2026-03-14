$!/usr/bin/env bash

for i in {1..5}; do
  echo "Fixing ns$i..."
  sudo ip netns exec ns$i bash -c "
    # 1. Enable Multicast on all veths
    for intf in \$(ls /sys/class/net/veth*); do
        name=\$(basename \$intf)
        ip link set \$name multicast on
        # 2. Disable Checksum Offloading (The OSPF Killer)
        ethtool -K \$name rx off tx off 2>/dev/null || true
        # 3. Disable Reverse Path Filtering
        echo 0 > /proc/sys/net/ipv4/conf/\$name/rp_filter
    done
    # Disable rp_filter globally in the namespace
    echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
    echo 0 > /proc/sys/net/ipv4/conf/default/rp_filter
  "
done

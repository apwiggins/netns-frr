#!/usr/bin/env bash
set -e

BASE_CONF="/tmp/etc/frr"
BASE_RUN="/var/run/frr"
LOG_DIR="/var/log/frr"
FRR_USER="frr"

# 1. Clean up and setup base directories
sudo pkill -9 zebra || true
sudo pkill -9 ospfd || true
sudo mkdir -p $BASE_CONF $BASE_RUN $LOG_DIR

for i in {1..5}; do
    ns="ns$i"
    CONF_DIR="$BASE_CONF/$ns"
    RUN_DIR="$BASE_RUN/$ns"

    sudo mkdir -p $CONF_DIR $RUN_DIR
    sudo chown -R $FRR_USER:$FRR_USER $CONF_DIR $RUN_DIR

# 2. Write Configs
# vtysh.conf
    sudo tee $CONF_DIR/vtysh.conf > /dev/null <<EOF
hostname $ns
EOF
    sudo chown $FRR_USER:$FRR_USER $CONF_DIR/vtysh.conf

# zebra.conf
    sudo tee $CONF_DIR/zebra.conf > /dev/null <<EOF
hostname $ns
password zebra
log file $LOG_DIR/$ns-zebra.log
EOF

# ospfd.conf
sudo tee $CONF_DIR/ospfd.conf > /dev/null <<EOF
hostname ospfd-$ns
password zebra
log file $LOG_DIR/$ns-ospfd.log
!
$(for j in {1..5}; do
    if [ $j -ne $i ]; then
        echo "interface veth${i}-${j}"
        echo " ip ospf network point-to-point"
    fi
done)
!
router ospf
$(for j in {1..5}; do
    if [ $i -ne $j ]; then
        # Determine the consistent subnet (lower number first)
        if [ $i -lt $j ]; then
            SUBNET="10.${i}.${j}.0"
        else
            SUBNET="10.${j}.${i}.0"
        fi

        echo " network ${SUBNET}/30 area 0"
    fi
done)
EOF
    sudo chown $FRR_USER:$FRR_USER $CONF_DIR/*.conf
done

# 3. Start Daemons
for i in {1..5}; do
    ns="ns$i"
    CONF_DIR="$BASE_CONF/$ns"
    RUN_DIR="$BASE_RUN/$ns"

    echo "Starting FRR in $ns..."

    # Zebra: Explicit config, pid, and pathspace
    sudo ip netns exec $ns /usr/sbin/zebra -d -N $ns \
        -f $CONF_DIR/zebra.conf \
        -i $RUN_DIR/zebra.pid \
        -u $FRR_USER

    # OSPF: Explicit config, pid, and pathspace
    # Note: -N $ns ensures it looks for zebra socket in /var/run/frr/$ns/
    sudo ip netns exec $ns /usr/sbin/ospfd -d -N $ns \
        -f $CONF_DIR/ospfd.conf \
        -i $RUN_DIR/ospfd.pid \
        -u $FRR_USER
done


printf "To connect to ns1: sudo ip netns exec ns1 vtysh -N ns1 \n"

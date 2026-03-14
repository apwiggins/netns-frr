#!/usr/bin/env bash

echo "--- OSPF FULL MESH CONNECTIVITY TEST ---"
for src in {1..5}; do
    for dst_node in {1..5}; do
        if [ $src -ne $dst_node ]; then
            # We will ping the IP that ns$dst_node uses to talk to ns1
            # (or any valid IP in that namespace)
            TARGET="10.1.${dst_node}.1"
            if [ "$dst_node" -eq "1" ]; then TARGET="10.1.2.1"; fi

            sudo ip netns exec ns${src} ping -c 1 -W 1 $TARGET > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "[ns${src} -> ns${dst_node}] PASS"
            else
                echo "[ns${src} -> ns${dst_node}] FAIL"
            fi
        fi
    done
done

#!/usr/bin/env bash

# Usage: ./nvtysh <namespace> [-c "command"]
NS=$1
shift

CONF_DIR="/tmp/etc/frr"
RUN_DIR="/var/run/frr"

# Check if the namespace exists
if [ -z "$NS" ] || ! ip netns list | grep -q "$NS"; then
    echo "Usage: nvtysh <namespace_name> [-c \"command\"]"
    exit 1
fi

# Execute vtysh. "$@" passes all remaining arguments (like -c "show ip route")
# If no arguments remain, it opens an interactive shell.
sudo ip netns exec "$NS" vtysh -N "$NS" \
  --vty_socket "$RUN_DIR/" \
  --config_dir "$CONF_DIR/" \
  "$@"

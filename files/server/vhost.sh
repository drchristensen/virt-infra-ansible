#!/bin/sh
# set -x
systemctl stop NetworkManager
IP=$(awk "/^[[:space:]]*($|#)/{next} /$HOSTNAME/{print \$1; exit}" /etc/hosts)
DEV="eth0"
echo "Setting the IP $IP for this host ($HOSTNAME) ..."
ip addr add $IP/24 dev $DEV

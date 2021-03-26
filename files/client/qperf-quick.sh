#!/bin/bash

# Enable debugging
# set -x

# Input Arguments:
# $1 - Assigned qperf port number
QPERF_PORT=$1

LOCAL_HOSTNAME=`hostname`
VM_INSTANCE=`echo $LOCAL_HOSTNAME | sed 's/.*-client-//'`
REM_HOSTNAME="dpdk-server-$VM_INSTANCE"
OUTFILE=instance-${2}.txt

echo "Server: $REM_HOSTNAME, Qperf port: $QPERF_PORT ..."
/usr/bin/qperf -lp $QPERF_PORT -t 1m -H $REM_HOSTNAME -m 8M --use_bits_per_sec tcp_bw

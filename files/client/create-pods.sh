#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

VM_HOSTNAME=`hostname`
CONTAINER_IMAGE="dpdk-client"
CONTAINERS=8
QPERF_DEFAULT_PORT=19765

cd /root

# Build a container if none present
if [[ "$(podman images -q $CONTAINER_IMAGE 2> /dev/null)" == "" ]]; then
  podman build -t $CONTAINER_IMAGE .
fi

for (( COUNT=0; COUNT<CONTAINERS; COUNT++ ))
do
    QPERF_PORT=$((QPERF_DEFAULT_PORT+COUNT))
    CONTAINER_NAME="cont-$COUNT"
    CONTAINER_SERVICE="container-$CONTAINER_NAME.service"
    # Note that the timezone mount may not work with all distros
    podman create -d --name $CONTAINER_NAME --hostname $CONTAINER_NAME -e QPERF_PORT=$QPERF_PORT -e VM_HOSTNAME=$VM_HOSTNAME -v /etc/localtime:/etc/localtime:ro -v /mnt/logs:/mnt/logs:z --network host $CONTAINER_IMAGE
    podman generate systemd --name $CONTAINER_NAME > /etc/systemd/system/$CONTAINER_SERVICE
    systemctl enable $CONTAINER_SERVICE
    systemctl start $CONTAINER_SERVICE
done

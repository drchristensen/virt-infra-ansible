#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

VM_HOSTNAME=`hostname`
CONTAINER_IMAGE="dpdk-server"
CONTAINERS=8
QPERF_DEFAULT_PORT=19765

cd /root

# Stop and delete any existing containers
for (( COUNT=0; COUNT<CONTAINERS; COUNT++ ))
do
    CONTAINER_NAME="cont-$COUNT"
    CONTAINER_SERVICE="container-$CONTAINER_NAME.service"
    systemctl disable $CONTAINER_SERVICE > /dev/null 2>&1
    systemctl stop $CONTAINER_SERVICE > /dev/null 2>&1
		rm -f /etc/systemd/system/$CONTAINER_SERVICE$ > /dev/null 2>&1
    podman rm $CONTAINER_NAME > /dev/null 2>&1
done

# Delete existing image
podman rmi exists $CONTAINER_IMAGE > /dev/null 2>&1 || true

# Build the container
#if [[ "$(podman images -q $CONTAINER_IMAGE 2> /dev/null)" == "" ]]; then
  podman build -t $CONTAINER_IMAGE .
#fi

# Create new containers and set them to run automatically
for (( COUNT=0; COUNT<CONTAINERS; COUNT++ ))
do
    QPERF_PORT=$((QPERF_DEFAULT_PORT+COUNT))
    CONTAINER_NAME="cont-$COUNT"
    CONTAINER_SERVICE="container-$CONTAINER_NAME.service"
    # Note that the timezone mount may not work with all distros
    podman create -d --name $CONTAINER_NAME --hostname $CONTAINER_NAME -e QPERF_PORT=$QPERF_PORT -e VM_HOSTNAME=$VM_HOSTNAME -v /etc/localtime:/etc/localtime:ro -v /mnt/logs:/mnt/logs --security-opt label=disable --network host $CONTAINER_IMAGE
    podman generate systemd --name $CONTAINER_NAME > /etc/systemd/system/$CONTAINER_SERVICE
    systemctl enable $CONTAINER_SERVICE
    systemctl start $CONTAINER_SERVICE
done

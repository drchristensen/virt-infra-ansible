#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

CONTAINERS=8

cd /root

for (( COUNT=0; COUNT<CONTAINERS; COUNT++ ))
do
    CONTAINER_NAME="cont-$COUNT"
    CONTAINER_SERVICE="container-$CONTAINER_NAME.service"
    echo "Starting service $CONTAINER_SERVICE ..."
    systemctl start $CONTAINER_SERVICE
done

#!/bin/bash
printenv | grep 'QPERF_PORT\|VM_HOSTNAME' > /root/container_env
sed -i '/INSERT-VARS-HERE/r /root/container_env' /etc/cron.d/qperf.cron
crond && tail -f /dev/null

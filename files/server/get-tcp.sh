#!/bin/bash

echo "Current tcp settings ..."
echo "------------------------"
sysctl net.ipv4.tcp_window_scaling
sysctl net.ipv4.tcp_slow_start_after_idle
sysctl net.ipv4.tcp_rmem
sysctl net.ipv4.tcp_wmem
sysctl net.core.rmem_default
sysctl net.core.wmem_default
sysctl net.core.rmem_max
sysctl net.core.wmem_max
sysctl net.core.optmem_max
sysctl net.core.netdev_max_backlog
sysctl net.ipv4.tcp_congestion_control
sysctl net.ipv4.tcp_timestamps
sysctl net.ipv4.tcp_sack

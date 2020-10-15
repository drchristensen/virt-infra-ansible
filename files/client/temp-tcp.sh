#!/bin/bash

#MAX_WIN=8388608
MAX_WIN=134217728
DEF_RMEM_WIN=87380
DEF_WMEM_WIN=65536

echo "Setting new tcp settings ..."
# Enable TCP window size scaling
sysctl -w net.ipv4.tcp_window_scaling=1

# Disable TCP slow start
sysctl -w net.ipv4.tcp_slow_start_after_idle=0

# Set the min, default and maximum receive window sizes used during auto tuning
sysctl -w net.ipv4.tcp_rmem="4096 ${DEF_RMEM_WIN} ${MAX_WIN}"
sysctl -w net.ipv4.tcp_wmem="4096 ${DEF_WMEM_WIN} ${MAX_WIN}"

# Set default window size, used when window size scaling is disabled
sysctl -w net.core.rmem_default=$DEF_RMEM_WIN
sysctl -w net.core.wmem_default=$DEF_WMEM_WIN

# Set max window size, used when window size scaling is disabled
sysctl -w net.core.rmem_max=$MAX_WIN
sysctl -w net.core.rmem_max=$MAX_WIN

# Set maximum buffer size allowed per socket
sysctl -w net.core.optmem_max=$MAX_WIN

# Set to something that’s a lot higher than default
sysctl -w net.core.netdev_max_backlog=250000

# Set the congestion control algorithm (test for your use case)
# sysctl -w net.ipv4.tcp_congestion_control=’cubic’

# Disable timestamps as defined in RFC1323 (reduces packet size)
sysctl -w net.ipv4.tcp_timestamps=0

# Enable select acknowledgments
sysctl -w net.ipv4.tcp_sack=1

# Force all new TCP connections to use the above settings
sysctl -w net.ipv4.route.flush=1

#!/bin/bash

# Enable debugging
# set -x

TEST_DATE=`date`

# Check the time in seconds since midnight
eval "$(date +'TODAY=%F NOW=%s')"
MIDNIGHT=$(date -d "$TODAY 0" +%s)
SEC="$((NOW - MIDNIGHT))"
MIN="$((SEC / 60))"

echo "Running $0 at $TEST_DATE ..."

CONT_NAME=`hostname`
CONT_INSTANCE=`echo $CONT_NAME | sed 's/cont-//'`
VM_NAME="dpdk-server-0"
VM_INSTANCE="0"
LOG_DIR="/mnt/logs"
LOG_FILE="$LOG_DIR/${MIN}_${VM_NAME}_${CONT_NAME}_qperf_${TEST_DATE}.txt"

echo "MIN = $MIN, VM_INSTANCE = $VM_INSTANCE, CONT_INSTANCE = $CONT_INSTANCE ..."
echo "LOG_FILE = $LOG_FILE ..."

run_test() {
  # Find the name of our matched qperf server
  REM_NAME="dpdk-server-$VM_INSTANCE"

  # The qperf port for the remote server is passed to the container as
  QPERF_PORT=19765

  # Create a test file for the qperf test results
  echo "local_vm_hostname: $VM_NAME"            > "$LOG_FILE"
  echo "remote_vm_hostname: $REM_NAME"         >> "$LOG_FILE"
  echo "local_container_hostname: $CONT_NAME"  >> "$LOG_FILE"
  echo "remote_container_hostname: $CONT_NAME" >> "$LOG_FILE"
  echo "remote_qperf_port: $QPERF_PORT"        >> "$LOG_FILE"
  echo "date: $TEST_DATE"                      >> "$LOG_FILE"
  echo "connections: $((2**TEST))"             >> "$LOG_FILE"
  echo "test_run: $MIN"                        >> "$LOG_FILE"

  # Actually run the test
  /usr/bin/qperf -vvc -vvs -vvu  -uu --use_bits_per_sec -t 1m -m 512K -H $REM_NAME -lp $QPERF_PORT tcp_bw >> "$LOG_FILE"
}

RUN="0"
TEST="0"
run_test

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

if (( $MIN % 30 )); then
	echo "Start time $MIN is not a multiple of 30, quitting ..."
	exit 0
fi

# Tests take ~18M to run so we schedule them to run every 30 minutes.
# Modify the value of TEST_INTERVAL to match the number of tests you
# want to execute per run.  Refer to the following table:
#
# Test # | VM #  | CONT # | # Tests | Interval
# -------+-------+--------+---------+---------
#    0   |   0   |   0    |     1   |    30
#    1   |   0   |  0-1   |     2   |    60
#    2   |   0   |  0-3   |     4   |    90
#    3   |   0   |  0-7   |     8   |   120
#    4   |  0-1  |  0-7   |    16   |   150
#    5   |  0-3  |  0-7   |    32   |   180
#    6   |  0-7  |  0-7   |    64   |   210
#    7   |  0-15 |  0-7   |   128   |   240
#    8   |  0-31 |  0-7   |   256   |   270
#    9   |  0-63 |  0-7   |   512   |   300
#
TEST_INTERVAL="270"

# Calculate the run number and the test number the script should be
# executing based on the number of minutes since midnight.
RUN=$(( MIN / TEST_INTERVAL ))
TEST=$(( (MIN - RUN * TEST_INTERVAL) / 30 ))
echo "This is run $RUN and test $TEST ..."

CONT_NAME=`hostname`
CONT_INSTANCE=`echo $CONT_NAME | sed 's/cont-//'`
VM_NAME=`echo $VM_HOSTNAME`
VM_INSTANCE=`echo $VM_NAME | sed 's/dpdk-client-//'`
LOG_DIR="/mnt/logs"
LOG_FILE="$LOG_DIR/${MIN}_${VM_NAME}_${CONT_NAME}_qperf_${TEST_DATE}.txt"

echo "MIN = $MIN, VM_INSTANCE = $VM_INSTANCE, CONT_INSTANCE = $CONT_INSTANCE ..."
echo "LOG_FILE = $LOG_FILE ..."

run_test() {
  # Find the name of our matched qperf server
  REM_NAME="dpdk-server-$VM_INSTANCE"

  # The qperf port for the remote server is passed to the container as
  # QPERF_PORT

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
  /usr/bin/qperf -vvc -vvs -vvu  -uu --use_bits_per_sec -t 1m -oo msg_size:64:8M:*2 -H $REM_NAME -lp $QPERF_PORT tcp_bw >> "$LOG_FILE"
}

case $TEST in
  0)
    if [[ $VM_INSTANCE -eq 0 && $CONT_INSTANCE -eq 0 ]]; then
      echo "Running test 0..."
      run_test
    else
      echo "Not running test 0 ..."
    fi
    ;;
  1)
    if [[ $VM_INSTANCE -eq 0 && $CONT_INSTANCE -le 1 ]]; then
      echo "Running test 1..."
      run_test
    else
      echo "Not running test 1 ..."
    fi
    ;;
  2)
    if [[ $VM_INSTANCE -eq 0 && $CONT_INSTANCE -le 3 ]]; then
      echo "Running test 2..."
      run_test
    else
      echo "Not running test 2 ..."
    fi
    ;;
  3)
    if [[ $VM_INSTANCE -eq 0 && $CONT_INSTANCE -le 7 ]]; then
      echo "Running test 3..."
      run_test
    else
      echo "Not running test 3 ..."
    fi
    ;;
  4)
    if [ $VM_INSTANCE -le 1 ]; then
      echo "Running test 4..."
      run_test
    else
      echo "Not running test 4 ..."
    fi
    ;;
  5)
    if [ $VM_INSTANCE -le 3 ]; then
      echo "Running test 5..."
      run_test
    else
      echo "Not running test 5 ..."
    fi
    ;;
  6)
    if [ $VM_INSTANCE -le 7 ]; then
      echo "Running test 6..."
      run_test
    else
      echo "Not running test 6 ..."
    fi
    ;;
  7)
    if [ $VM_INSTANCE -le 15 ]; then
      echo "Running test 7..."
      run_test
    else
      echo "Not running test 7 ..."
    fi
    ;;
  8)
    if [ $VM_INSTANCE -le 31 ]; then
      echo "Running test 8..."
      run_test
    else
      echo "Not running test 8 ..."
    fi
    ;;
  9)
    echo "Running test 9..."
    run_test
    ;;
  *)
    echo "Unknown test ..."
    ;;
esac

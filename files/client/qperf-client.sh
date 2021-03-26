#!/bin/bash

# Enable debugging
# set -x

# Input Arguments:
# $1 - Qperf port number
QPERF_PORT=$1
QPERF_INSTANCE=$(( QPERF_PORT - 19765 ))

# Capture the current time of the test run
TEST_DATE=`date`

# Check the time in seconds since midnight
eval "$(date +'TODAY=%F NOW=%s')"
MIDNIGHT=$(date -d "$TODAY 0" +%s)
SEC="$((NOW - MIDNIGHT))"
MIN="$((SEC / 60))"

echo "Running $0 at $TEST_DATE ..."

##############################################
# Begin customizations
##############################################
# Tests take ~18 minutes to run so we schedule them to run every 30
# minutes. Modify the value of TEST_INTERVAL to match the number of
# tests you want to execute per run.  Refer to the following table:
#
# Test # | VM #  | QPRF # | # Tests | Interval
# -------+-------+--------+---------+---------
#    0   |   0   |     1  |     1   |    30
#    1   |   0   |   1-2  |     2   |    60
#    2   |   0   |   1-3  |     4   |    90
#    3   |   0   |   1-8  |     8   |   120
#    4   |   0   |  1-16  |    16   |   150
#    5   |  0-1  |  1-16  |    32   |   180
#    6   |  0-3  |  1-16  |    64   |   210
#    7   |  0-7  |  1-16  |   128   |   240
#
TEST_INTERVAL="210"
##############################################
# End customizations
##############################################

# Calculate the run number and the test number the script should be
# executing based on the number of minutes since midnight.
RUN=$(( MIN / TEST_INTERVAL ))
TEST=$(( (MIN - RUN * TEST_INTERVAL) / 30 ))
echo "This is run $RUN and test $TEST ..."

LOCAL_HOSTNAME=`hostname`
VM_INSTANCE=`echo $LOCAL_HOSTNAME | sed 's/.*-client-//'`
LOG_DIR="/mnt/logs"
LOG_FILE="$LOG_DIR/$(printf "%04d" $MIN)_${LOCAL_HOSTNAME}_qperf_${QPERF_INSTANCE}_${TEST_DATE}.txt"

echo "LOG_FILE = $LOG_FILE ..."

run_test() {
  # The qperf port for the remote server is calculated as the default
  # qperf port number () plus the instance number (QPERF_INSTANCE)
  REM_HOSTNAME=`hostname | sed 's/-client-/-server-/'`

  # Create a test file for the qperf test results
  echo "local_vm_hostname: $LOCAL_HOSTNAME"     > "$LOG_FILE"
  echo "remote_vm_hostname: $REM_HOSTNAME"     >> "$LOG_FILE"
  echo "qperf_instance: $QPERF_INSTANCE"       >> "$LOG_FILE"
  echo "remote_qperf_port: $QPERF_PORT"        >> "$LOG_FILE"
  echo "date: $TEST_DATE"                      >> "$LOG_FILE"
  echo "connections: $((2**TEST))"             >> "$LOG_FILE"
  echo "test_run: $MIN"                        >> "$LOG_FILE"

  # Sleep for a minute, allow time for the qperf server to start
  sleep 60s

  # Actually run the test
  /usr/bin/qperf -vvc -vvs -vvu  -uu --use_bits_per_sec -t 1m -oo msg_size:64:8M:*2 -H $REM_HOSTNAME -lp $QPERF_PORT tcp_bw >> "$LOG_FILE"
}

case $TEST in
  0)
    if [[ $VM_INSTANCE -eq 0 && $QPERF_INSTANCE -eq 1 ]]; then
      echo "Running test 0..."
      run_test
    else
      echo "Not running test 0 ..."
    fi
    ;;
  1)
    if [[ $VM_INSTANCE -eq 0 && $QPERF_INSTANCE -le 2 ]]; then
      echo "Running test 1..."
      run_test
    else
      echo "Not running test 1 ..."
    fi
    ;;
  2)
    if [[ $VM_INSTANCE -eq 0 && $QPERF_INSTANCE -le 4 ]]; then
      echo "Running test 2..."
      run_test
    else
      echo "Not running test 2 ..."
    fi
    ;;
  3)
    if [[ $VM_INSTANCE -eq 0 && $QPERF_INSTANCE -le 8 ]]; then
      echo "Running test 3..."
      run_test
    else
      echo "Not running test 3 ..."
    fi
    ;;
  4)
    if [[ $VM_INSTANCE -eq 0 && $QPERF_INSTANCE -le 16 ]]; then
      echo "Running test 4..."
      run_test
    else
      echo "Not running test 4 ..."
    fi
    ;;
  5)
    if [ $VM_INSTANCE -le 1 ]; then
      echo "Running test 5..."
      run_test
    else
      echo "Not running test 5 ..."
    fi
    ;;
  6)
    if [ $VM_INSTANCE -le 3 ]; then
      echo "Running test 6..."
      run_test
    else
      echo "Not running test 6 ..."
    fi
    ;;
  7)
    if [ $VM_INSTANCE -le 7 ]; then
      echo "Running test 7..."
      run_test
    else
      echo "Not running test 7 ..."
    fi
    ;;
  *)
    echo "Unknown test ..."
    ;;
esac

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

#
# There are 7 tests in a run, 0-6, and the tests take ~18M to run.
# If we schedule the tests to run every 30 minutes through cron,
# we can expect 6 complete runs in a day at the following interval
# (minutes since midnight): [0, 210, 420, 630, 840, 1050]
#
# Calculate the run number and the test number the script should be
# executing based on the number of minutes since midnight.

RUN="0"
for (( ITEM=0; ITEM < 1440 && ITEM <= MIN; ITEM+=210 ));
do
#  echo "ITEM is $ITEM ..."
  if [[ "$MIN" -ge "$ITEM" && "$MIN" -lt $((ITEM + 210)) ]]; then
    break
  fi
  RUN=$((RUN + 1))
done

# Make sure we're in range
if [ "$RUN" -gt 6 ]; then
  echo "Not a valid time to run the script..."
  exit 0
fi

TEST="0"
for (( ITEM=$((RUN * 210)); ITEM < $((RUN * 210 + 210)); ITEM+=30 ));
do
  if [ "$ITEM" == "$MIN" ]; then
    break
  fi
  TEST=$((TEST + 1))
done

# Make sure we're in range
if [ "$TEST" -gt 6 ]; then
  echo "Not a valid time to run the script..."
  exit 1
fi

echo "RUN = $RUN, TEST = $TEST ..."

#
# The following table shows when a test should be run in
# a container:
#
# Test # | VM # | CONT # | # Tests
# -------+------+--------+--------
#    0   |   0  |   0    |    1
#    1   |   0  |  0-1   |    2
#    2   |   0  |  0-3   |    4
#    3   |   0  |  0-7   |    8
#    4   |  0-1 |  0-7   |   16
#    5   |  0-3 |  0-7   |   32
#    6   |  0-7 |  0-7   |   64
#

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
    echo "Running test 6..."
    run_test
    ;;
  *)
    echo "Unknown test ..."
    ;;
esac

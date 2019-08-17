#!/bin/bash

#CONSTANTS
MNT=/mnt/ramdisk
INPUT_FILE=$MNT/input
OUTPUT_FILE=$MNT/output
COUNT=1000
TIMING_STATS_FILE="/proc/fs/NOVA/pmem2/timing_stats"
FROM_SNAPSHOT=/tmp/before.ts
TO_SNAPSHOT=/tmp/after.ts

INPUT_FILE_SIZE=4G
CMD_PREFIX="numactl -N 0 -m 0 "
DIFF_NTS=../../utils/diff_nts.py
MOUNT_FS=../../utils/mount_fs.sh

TOTAL_EXP=1

################################################################################
### Helper Functions ###########################################################
function dd_prepare() {
    $MOUNT_FS nova-timing /dev/pmem2 /mnt/ramdisk
    if [ ! -f $INPUT_FILE ]; then
        head -c $INPUT_FILE_SIZE /dev/urandom > $INPUT_FILE
    fi

    if [ -f $OUTPUT_FILE ]; then
        rm -f $OUTPUT_FILE
    fi

	cat $TIMING_STATS_FILE > $FROM_SNAPSHOT
}

function dd_postpare() {
    RESULT_FILE=$1
    echo $RESULT_FILE
	cat $TIMING_STATS_FILE > $TO_SNAPSHOT
    $DIFF_NTS $FROM_SNAPSHOT $TO_SNAPSHOT >> $RESULT_FILE
    ls -al $MNT >> $RESULT_FILE
}
################################################################################

################################################################################
### Main #######################################################################
for i in `seq 1 $TOTAL_EXP`; do 
    for BLOCK_SIZE in 4096 16384 65536 262144 1048576 4194304; do

        ### Subzero execution
        SUBZERO_RESULT_FILE="type_subzero.bs_$BLOCK_SIZE.err"

        # subzero prepare
        dd_prepare

        # subzero execute
        CMD="$CMD_PREFIX ./src/dd if=$INPUT_FILE of=$OUTPUT_FILE bs=$BLOCK_SIZE count=$COUNT iflag=fullblock"
        echo $CMD >> $SUBZERO_RESULT_FILE
        $($CMD >> $SUBZERO_RESULT_FILE 2>&1)

        # subzero postpare
        dd_postpare $SUBZERO_RESULT_FILE

        ### Vanilla execution
        DEFAULT_RESULT_FILE="type_default.bs_$BLOCK_SIZE.err"

        # vanilla prepare
        dd_prepare

        # vanilla execute
        CMD="$CMD_PREFIX ../default_coreutils/src/dd if=$INPUT_FILE of=$OUTPUT_FILE bs=$BLOCK_SIZE count=$COUNT iflag=fullblock"
        echo $CMD >> $DEFAULT_RESULT_FILE
        $($CMD_PREFIX $CMD >> $DEFAULT_RESULT_FILE 2>&1)

        # vanilla postpare
        dd_postpare $DEFAULT_RESULT_FILE

        ### Print out to std
        echo "================================================================="
        echo "Exp#: $i, BlockSize: $BLOCK_SIZE"
        ./analyze_result.py $DEFAULT_RESULT_FILE $SUBZERO_RESULT_FILE
        echo "================================================================="
    done
done
################################################################################

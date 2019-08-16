#!/bin/bash
MNT=/mnt/ramdisk
INPUT_FILE=$MNT/input
OUTPUT_FILE=$MNT/output
COUNT=1000

INPUT_FILE_SIZE=4G

CMD_PREFIX="numactl -N 0 -m 0 "
for BLOCK_SIZE in 4096 16384 65536 262144 1048576 4194304; do
    ./utils/mount_fs.sh nova /dev/pmem2 /mnt/ramdisk

    # Subzero execution
    if [ ! -f $INPUT_FILE ]; then
        head -c $INPUT_FILE_SIZE /dev/urandom > $INPUT_FILE
    fi

    if [ -f $OUTPUT_FILE ]; then
        rm -f $OUTPUT_FILE
    fi

    CMD="$CMD_PREFIX ./src/dd if=$INPUT_FILE of=$OUTPUT_FILE bs=$BLOCK_SIZE count=$COUNT iflag=fullblock"
    echo $CMD
    $CMD_PREFIX $CMD

    ls -al $MNT

    # normal execution
    ./utils/mount_fs.sh nova /dev/pmem2 /mnt/ramdisk

    if [ ! -f $INPUT_FILE ]; then
        head -c $INPUT_FILE_SIZE /dev/urandom > $INPUT_FILE
    fi

    if [ -f $OUTPUT_FILE ]; then
        rm -f $OUTPUT_FILE
    fi

    CMD="$CMD_PREFIX ../default_coreutils/src/dd if=$INPUT_FILE of=$OUTPUT_FILE bs=$BLOCK_SIZE count=$COUNT iflag=fullblock"
    echo $CMD
    $CMD_PREFIX $CMD

    ls -al $MNT

done

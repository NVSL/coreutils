#!/bin/bash

FLAG=0
CMD_PREFIX="numactl -N 0 -m 0 "
for BLOCK_SIZE in 4096 16384 65536 262144 1048576 4194304; do
    # echo "---------------------------------------------------------------------"
    # echo "Block Size: $BLOCK_SIZE"
 
    # normal execution
    DEFAULT_RESULT_FILE="type_default.bs_$BLOCK_SIZE.err"
	# awk 'NR==3{print}' $DEFAULT_RESULT_FILE

    # Subzero execution
    SUBZERO_RESULT_FILE="type_subzero.bs_$BLOCK_SIZE.err"
	# awk 'NR==3{print}' $SUBZERO_RESULT_FILE

    if [ $FLAG -eq 0 ]; then
        ./analyze_result.py --simple $DEFAULT_RESULT_FILE $SUBZERO_RESULT_FILE
        FLAG=1
    else
        ./analyze_result.py --simple --no-header $DEFAULT_RESULT_FILE $SUBZERO_RESULT_FILE
    fi

	#../../analyze_ts_diff.py $DEFAULT_RESULT_FILE $SUBZERO_RESULT_FILE
    
done

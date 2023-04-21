#!/bin/bash

# main for SMPT tool
# run from within execution dir

echoerr() { echo "$@" 1>&2; }

# We only compete in the Reachability category.
if [ "$BK_EXAMINATION" != "ReachabilityCardinality" ] && [ "$BK_EXAMINATION" != "ReachabilityFireability" ]
then echoerr Reachability False; echo DO_NOT_COMPETE; exit 0
else echoerr Reachability True
fi

if [ "$BK_EXAMINATION" == "ReachabilityFireability" ]
then fireability="--fireability"
else fireability=""
fi

# time confinement
total_time=$BK_TIME_CONFINEMENT


export PATH=$BK_BIN_PATH:$PATH

# set environment variables
if [ -f large_marking ]
then
    echoerr large_marking
    # from tin 3.7.0 there only is tina64
#    export PATH=/opt/python/3.11.2/bin:$home/bin:$home/bin/tina-int64/:$home/bin/latte/bin:$home/bin/z3/bin:$home/bin/Octant:$PATH
    project=""
else
#    export PATH=/opt/python/3.11.2/bin:$home/bin:$home/bin/tina/:$home/bin/latte/bin:$home/bin/z3/bin:$home/bin/Octant:$PATH
    project="--project"
fi

# set memory limit
MEM=$(( 1000*BK_MEMORY_CONFINEMENT ))
ulimit -v $MEM

# SMPT options
#
timeout="--global-timeout $total_time"
reduce="--auto-reduce"
methods="--methods DUMMY"
mcc="--mcc"
techniques="--show-techniques"
#
# colored option
if [ `cat iscolored` == "TRUE" ]
then
    echoerr Colored True
    colored="--colored"
else
    echoerr Colored False
    colored=""
fi
#
# input model
model="-n $(pwd)/model.pnml"
#
# properties
properties="--xml $(pwd)/$BK_EXAMINATION.xml"

# main
# cd $home/bin/SMPT
while ! smpt.exe $model $colored $reduce $project $properties $fireability $timeout $methods $mcc $techniques ; do
    echo "# RESTARTING SMPT"
done

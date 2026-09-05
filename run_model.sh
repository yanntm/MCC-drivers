#! /bin/bash

# Run every examination we have an oracle for, on one model instance.
#   ./run_model.sh AirplaneLD-PT-0010 [-t 60] [extra flags for BenchKit_head.sh]
# BK_TOOL selects the tool folder (default itstools).
# One log per examination in logs/<model>/, plus a one line summary per test.

MODEL=$1
shift

export BK_TOOL=${BK_TOOL:-itstools}
LOGDIR=logs/$MODEL
mkdir -p $LOGDIR

rc=0
for ORACLE in oracle/$MODEL-*.out ; do
	EXAM=$(basename $ORACLE .out | sed "s/^$MODEL-//")
	./run_test.pl $ORACLE "$@" > $LOGDIR/$EXAM.log 2>&1
	code=$?
	if [ $code == 0 ] ; then verdict=PASS ; else verdict="FAIL($code)" ; rc=1 ; fi
	printf '%-10s %-6s %s\n' "$EXAM" "$verdict" "$LOGDIR/$EXAM.log"
done
exit $rc

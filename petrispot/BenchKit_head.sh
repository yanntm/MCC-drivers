#!/bin/bash

# MCC driver for PetriSpot's explicit heuristic walk engine (P/T nets,
# reachability examinations only). Invoked with the model folder as working
# directory (model.pnml, <Examination>.xml) and the BK_* variables set.
#
# Tunables (environment):
#   PETRISPOT_THREADS     walkers in parallel (default 4, the MCC core count)
#   PETRISPOT_STRATEGIES  strategy pool, name[:epsilon[:stall]],... (default below)
#   PETRISPOT_FLAGS       extra flags appended verbatim (e.g. "--share=32")
#   PETRISPOT_MARGIN      seconds kept off the confinement for start-up (default 5)

echo "PetriSpot driver: BK_EXAMINATION=$BK_EXAMINATION BK_INPUT=$BK_INPUT BK_TIME_CONFINEMENT=$BK_TIME_CONFINEMENT"

DIR=$(dirname "${BASH_SOURCE[0]}")
PETRI=${PETRISPOT_BIN_RUN:-$DIR/bin/petri64}
THREADS=${PETRISPOT_THREADS:-4}
STRATEGIES=${PETRISPOT_STRATEGIES:-random,bestfirst:10:2000,structural:10:2000,relaxed:0:300}
MARGIN=${PETRISPOT_MARGIN:-5}

if [ -z "$BK_TIME_CONFINEMENT" ] ; then BK_TIME_CONFINEMENT=3600 ; fi
TOTAL=$((BK_TIME_CONFINEMENT - MARGIN))
if [ "$TOTAL" -le 0 ] ; then TOTAL=1 ; fi

# memory confinement is in MB; keep a little headroom
if [ -n "$BK_MEMORY_CONFINEMENT" ] ; then
	ulimit -v $(( (BK_MEMORY_CONFINEMENT - 256) * 1024 ))
fi

if [ ! -x "$PETRI" ] ; then
	echo "PetriSpot binary not found at $PETRI (run install.sh)"
	echo "CANNOT_COMPUTE"
	exit 1
fi

case "$BK_EXAMINATION" in
	ReachabilityCardinality|ReachabilityFireability)
		if [ ! -f "$BK_EXAMINATION.xml" ] ; then
			echo "Property file $BK_EXAMINATION.xml not found."
			echo "CANNOT_COMPUTE"
			exit 1
		fi
		echo "$PETRI -i model.pnml --props=$BK_EXAMINATION.xml --threads=$THREADS --strategies=$STRATEGIES --totalTime=$TOTAL --roundTime=1 -q $PETRISPOT_FLAGS"
		"$PETRI" -i model.pnml --props="$BK_EXAMINATION.xml" --threads="$THREADS" --strategies="$STRATEGIES" --totalTime="$TOTAL" --roundTime=1 -q $PETRISPOT_FLAGS
		;;
	ReachabilityDeadlock)
		echo "$PETRI -i model.pnml --findDeadlock --threads=$THREADS -t $TOTAL -q $PETRISPOT_FLAGS"
		"$PETRI" -i model.pnml --findDeadlock --threads="$THREADS" -t "$TOTAL" -q $PETRISPOT_FLAGS
		;;
	*)
		echo "Examination $BK_EXAMINATION is not supported by PetriSpot."
		echo "DO_NOT_COMPETE"
		exit 0
		;;
esac
exit 0

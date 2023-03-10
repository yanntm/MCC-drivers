#!/bin/bash
#############################################################################
# In this script, you will affect values to your tool in order to let
# BenchKit launch it in an apropriate way.
#############################################################################

# BK_EXAMINATION: it is a string that identifies your "examination"

export PATH="$PATH:$BK_BIN_PATH"

MARCIE_CONFIG="--memory=6 --mcc-mode"
TIMEOUT="timeout --kill-after=10s --signal=SIGINT 1m"
MARCIE="${BK_BIN_PATH}marcie"


case "$BK_EXAMINATION" in

  StateSpace)
    echo "${TIMEOUT} for testing only"
    ${MARCIE} --net-file=model.pnml ${MARCIE_CONFIG}
  ;;

  UpperBounds)
    echo "${TIMEOUT} for testing only"
    ${MARCIE} --net-file=model.pnml --mcc-file=${BK_EXAMINATION}.xml ${MARCIE_CONFIG}
  ;;

  ReachabilityDeadlock)
  	# special case for deadlocks, MCC used to provide a file but does not any more.
    echo "${TIMEOUT} for testing only"    
    ${MARCIE} --net-file=model.pnml --mcc-file=${BK_BIN_PATH}/ReachabilityDeadlock.xml ${MARCIE_CONFIG}
  ;;


  Reachability*)
    echo "${TIMEOUT} for testing only"
    ${MARCIE} --net-file=model.pnml --mcc-file=${BK_EXAMINATION}.xml ${MARCIE_CONFIG}
  ;;

  CTL*)
    echo "${TIMEOUT} for testing only"
    ${MARCIE} --net-file=model.pnml --mcc-file=${BK_EXAMINATION}.xml ${MARCIE_CONFIG}
  ;;

  LTL*)
    echo "DO_NOT_COMPETE"
  ;;

  *)
  	# other examinations that are not supported : OneSafe, StableMarking, QuasiLiveness, Liveness
  	echo "DO_NOT_COMPETE"
    echo "$0: Wrong invocation:" >> $BK_LOG_FILE
    exit 1
    ;;
esac

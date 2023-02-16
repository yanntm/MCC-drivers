#!/bin/bash
#############################################################################
# This is an example for the MCC'2015
#############################################################################

#############################################################################
# In this script, you will affect values to your tool in order to let
# BenchKit launch it in an apropriate way.
#############################################################################

# BK_EXAMINATION: it is a string that identifies your "examination"

export PATH="$PATH:$BK_BIN_PATH"


# unfold step
grep "TRUE" iscolored > /dev/null
if [ $? == 0 ]; then
    $BK_BIN_PATH'/itstools/its-tools' '-pnfolder' '.' '-examination' $BK_EXAMINATION '--reduce-single' 'STATESPACE'   
    # patch resulting file name
    mkdir -p unf$BK_EXAMINATION
    mv model.STATESPACE.pnml unf$BK_EXAMINATION/model.pnml
	if [ -f $BK_EXAMINATION.xml ] ; then 
		mv $BK_EXAMINATION.STATESPACE.xml unf$BK_EXAMINATION/$BK_EXAMINATION.xml 
	fi
	cd unf$BK_EXAMINATION
fi


case "$BK_EXAMINATION" in

# these are currently disabled (less than 100% accurate)
# CTLCardinality|CTLFireability|
	ReachabilityCardinality|ReachabilityFireability|StateSpace|UpperBounds|OneSafe|Liveness|StableMarking|QuasiLiveness|ReachabilityDeadlock)
		$BK_BIN_PATH/smart.sh $BK_EXAMINATION | tee $BK_BIN_PATH/../log
		;;
#	Reachability*)
#                echo "DO_NOT_COMPETE"
#                ;;	

	CTL*)
		echo "DO_NOT_COMPETE"
		;;
	
	LTL*)
		echo "DO_NOT_COMPETE"
		;;

	*)
		echo "$0: Wrong invocation:" >> $BK_LOG_FILE
		exit 1
		;;
esac

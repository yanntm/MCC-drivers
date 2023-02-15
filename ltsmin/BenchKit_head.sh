#!/bin/bash
#############################################################################
# This is an example for the MCC'2015
#############################################################################

#############################################################################
# In this script, you will affect values to your tool in order to let
# BenchKit launch it in an apropriate way.
#############################################################################

# BK_EXAMINATION: it is a string that identifies your "examination"

TIME_CONFINEMENT=$((${BK_TIME_CONFINEMENT-3600}-30))

F_PREFIX=${F_PREFIX-"/tmp"}
mkdir -p "$F_PREFIX"
F_PREFIX="--prefix=$F_PREFIX"

EXTRA_TECHNIQUES=""

hostname 1>&2

grep "TRUE" iscolored > /dev/null
if [ $? == 0 ]; then
    echo "DO_NOT_COMPETE"
    exit 1
fi

case "$BK_EXAMINATION" in

	StateSpace)
		{ stderr=$(pnml2lts-sym model.pnml --lace-workers=4 --vset=lddmc --saturation=sat -rw2W,ru,bs,hf \
		 --sylvan-sizes=20,28,20,28 --maxsum 2>&1 1>&3-) ;} 3>&1
		echo "$stderr" 1>&2
		
		echo "$stderr" | grep "Got invalid permutation from boost" > /dev/null
		if [ $? -eq 0 ]; then
		    { stderr=$(pnml2lts-sym model.pnml --lace-workers=4 --vset=lddmc --saturation=sat -rw2W,ru,f,rs,hf \
		    --sylvan-sizes=20,28,20,28 --maxsum 2>&1 1>&3-) ;} 3>&1
		    echo "$stderr" 1>&2
		fi
		
		echo "$stderr" | grep "Exploration took" > /dev/null
        not_completed=$?
        if [[ $not_completed == 1 ]]; then
            echo "CANNOT_COMPUTE"
        else
		    states=$(echo "$stderr" | grep "state space has" | cut -d' ' -f 5)
		    max_place=$(echo "$stderr" | grep "max token count" | cut -d' ' -f 5)
		    max_sum=$(echo "$stderr" | grep "Maximum sum of all integer type state variables is:" | cut -d' ' -f 11)
		    echo "STATE_SPACE STATES $states TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
		    echo "STATE_SPACE TRANSITIONS -1 TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
		    echo "STATE_SPACE MAX_TOKEN_PER_MARKING $max_sum TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
		    echo "STATE_SPACE MAX_TOKEN_IN_PLACE $max_place TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
        fi
		
		;;
    
    UpperBounds)
        line=$(python3 $HOME/BenchKit/formulizer.py upper-bounds "$BK_EXAMINATION".xml --timeout=$TIME_CONFINEMENT --backend=sym "$F_PREFIX")

        if [ $? -ne 0 ]; then
            echo "could not parse formula" 1>&2
            echo "DO_NOT_COMPETE"
            exit 0
        fi

        { stderr=$(eval $line 2>&1 1>&3-) ;} 3>&1
        echo "$stderr" 1>&2

        names=$(echo "$stderr" | grep "ub formula name" | cut -d' ' -f4)
        for name in $names; do
            other=$(echo "$stderr" | grep -A1 "ub formula name $name$")
            formula=$(echo "$other" | grep -m1 "ub formula formula --maxsum=" | cut -d'=' -f2)
            max_sum=$(echo "$stderr" | grep "Maximum sum of $formula is:" | cut -d' ' -f 7)

            echo "$stderr" | grep "Maximum sum of $formula is:" > /dev/null
            computed=$?

            if [ $computed == 0 ]; then
                echo "FORMULA $name $max_sum TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"                        
            else
                echo "FORMULA $name CANNOT_COMPUTE"
            fi
        done
        ;;
 
	*)
		echo "DO_NOT_COMPETE"
		exit 0
		;;
esac

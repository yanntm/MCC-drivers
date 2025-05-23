#!/bin/bash
#############################################################################
# This is an example for the MCC'2015
#############################################################################

#############################################################################
# In this script, you will affect values to your tool in order to let
# BenchKit launch it in an apropriate way.
#############################################################################

# BK_EXAMINATION: it is a string that identifies your "examination"

# configure LTSmin to use a maximum of XGB of memory, this is neccessary
# because sysconf does not work in docker
# cg_ does not work on cluster with OAR but not cg_memory set
# cannot bound LTSmin memory if in portfolio with other methods...
# Basically guessing available memory and trying to take it all is a FBI
# "Fausse Bonne Idee",
# e.g. it will never support two LTSmin running different problems in parallel.
# 4 << 30 = 4294967296  4GB
# 8 << 30 = 8589934592  8GB
# 15 << 30 = 16106127360  15GB
# 16 << 30 = 17179869184  16GB

if [[ -z "${LTSMIN_MEM_SIZE}" ]]; then
    export LTSMIN_MEM_SIZE=1000000000
fi

# NOTE : the MEM limit value has been set to a lower value as higher values could cause various crashes.

export PATH=$BK_BIN_PATH:$PATH

TIME_CONFINEMENT=$((${BK_TIME_CONFINEMENT-3600}-30))

F_PREFIX=${F_PREFIX-"/tmp/$$"}
mkdir -p "$F_PREFIX"
F_PREFIX="--prefix=$F_PREFIX"

EXTRA_TECHNIQUES=""

hostname 1>&2


case "$BK_EXAMINATION" in

	StateSpace)
		{ stderr=$(pnml2lts-sym model.pnml --precise --vset=lddmc --saturation=sat -rw2W,ru,bs,hf \
		 --sylvan-sizes=20,28,20,28 --maxsum 2>&1 1>&3-) ;} 3>&1
		echo "$stderr" 1>&2
		
		echo "$stderr" | grep "Got invalid permutation from boost" > /dev/null
		if [ $? -eq 0 ]; then
		    { stderr=$(pnml2lts-sym model.pnml --precise --vset=lddmc --saturation=sat -rw2W,ru,f,rs,hf \
		    --sylvan-sizes=20,28,20,28 --maxsum 2>&1 1>&3-) ;} 3>&1
		    echo "$stderr" 1>&2
		fi
		
		echo "$stderr" | grep "Exploration took" > /dev/null
        not_completed=$?
        if [[ $not_completed == 1 ]]; then
            echo "CANNOT_COMPUTE"
        else
		    states=$(echo "$stderr" | grep "state space has precisely" | cut -d ' ' -f 6)
		    if [ -z $states ] ; then 
		    	states=$(echo "$stderr" | grep "state space has" | cut -d' ' -f 5) 
		    fi		    	    
		    max_place=$(echo "$stderr" | grep "max token count" | cut -d' ' -f 5)
		    max_sum=$(echo "$stderr" | grep "Maximum sum of all integer type state variables is:" | cut -d' ' -f 11)
		    echo "STATE_SPACE STATES $states TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
#		    echo "STATE_SPACE TRANSITIONS -1 TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
		    echo "STATE_SPACE MAX_TOKEN_PER_MARKING $max_sum TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
		    echo "STATE_SPACE MAX_TOKEN_IN_PLACE $max_place TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
        fi
		
		;;
    
    UpperBounds)
        line=$(python3 $BK_BIN_PATH/formulizer.py upper-bounds "$BK_EXAMINATION".xml --timeout=$TIME_CONFINEMENT --backend=sym "$F_PREFIX")

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
                echo "Could not compute solution for formula : $name"
            fi
        done
        ;;
	Reachability*)
	    case "$BK_EXAMINATION" in	    
	        ReachabilityDeadlock)
	            line=$(python3 $BK_BIN_PATH/formulizer.py deadlock $BK_BIN_PATH/ReachabilityDeadlock.xml --timeout=$TIME_CONFINEMENT --backend=sym "$F_PREFIX")
        
                if [ $? -ne 0 ]; then
                    echo "could not parse formula" 1>&2
		            echo "DO_NOT_COMPETE"
		            exit 0
                fi
                
                { stderr=$(eval $line 2>&1 1>&3-) ;} 3>&1
                echo "$stderr" 1>&2
                
                echo "$stderr" | grep "Got invalid permutation from boost" > /dev/null
	            if [ $? -eq 0 ]; then
	                line=$(python3 $BK_BIN_PATH/formulizer.py deadlock ReachabilityDeadlock.xml --timeout=$TIME_CONFINEMENT --backend=sym --reorder="w2W,ru,f,rs,hf")
            
                    if [ $? -ne 0 ]; then
                        echo "could not parse formula" 1>&2
		                echo "DO_NOT_COMPETE"
		                exit 0
                    fi
                    
                    { stderr=$(eval $line 2>&1 1>&3-) ;} 3>&1
                    echo "$stderr" 1>&2
	            fi
                
	            echo "$stderr" | grep "Exploration took" > /dev/null
                not_completed=$?
                name=$(echo "$stderr" | grep "property name is" | cut -d' ' -f4-)
                echo "$stderr" | grep "deadlock found" > /dev/null

                if [[ $? == 0 ]]; then
                    echo "FORMULA $name TRUE TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
                else
                    
                    if [[ $not_completed == 1 ]]; then
                        echo "Could not compute solution for formula : $name"
                    else
                        echo "FORMULA $name FALSE TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
                    fi
                fi
	        ;;
            ReachabilityFireability|ReachabilityCardinality)
            
                extraopts=""
                
                if [ "$BK_EXAMINATION" = "ReachabilityFireability" ]; then
                    extraopts="--extraopts=--inv-bin-par"
                fi
                
                line=$(python3 $BK_BIN_PATH/formulizer.py reachability "$BK_EXAMINATION".xml --timeout=$TIME_CONFINEMENT --backend=sym $extraopts "$F_PREFIX")
                
                if [ $? -ne 0 ]; then
                    echo "could not parse formula" 1>&2
		            echo "DO_NOT_COMPETE"
		            exit 0
                fi
                
                { stderr=$(eval $line 2>&1 1>&3-) ;} 3>&1
                echo "$stderr" 1>&2
                
                echo "$stderr" | grep "Got invalid permutation from boost" > /dev/null
	            if [ $? -eq 0 ]; then
	                line=$(python3 $BK_BIN_PATH/formulizer.py reachability "$BK_EXAMINATION".xml --timeout=$TIME_CONFINEMENT --backend=sym $extraopts --reorder="w2W,ru,f,rs,hf" "$F_PREFIX")
            
                    if [ $? -ne 0 ]; then
                        echo "could not parse formula" 1>&2
		                echo "DO_NOT_COMPETE"
		                exit 0
                    fi
                    
                    { stderr=$(eval $line 2>&1 1>&3-) ;} 3>&1
                    echo "$stderr" 1>&2
	            fi
                
                formulas=$(echo "$stderr" | grep "rfs formula name")
                                
                echo "$stderr" | grep "Exploration took" > /dev/null
                not_completed=$?
                echo "$stderr" | grep "all invariants violated" > /dev/null
                all_violated=$?                
                
                while read -r line; do
                    name=$(echo "$line" | cut -d' ' -f4-)
                    other=$(echo "$stderr" | grep -A2 "rfs formula name $name$")
                    type=$(echo "$other" | grep "rfs formula type" | cut -d' ' -f4-)
                    formula=$(echo "$other" | grep -m1 "rfs formula formula --invariant=" | cut -d'=' -f2)
                    echo "$stderr" | grep "Invariant violation ($formula)" > /dev/null
                    result=$?
                    if [[ $result == 0 ]]; then
                        if [[ $type == "EF" ]]; then
    	                    echo "FORMULA $name TRUE TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
                        else                         
    	                    echo "FORMULA $name FALSE TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
                        fi
                    else
                        if [[ $not_completed == 1 ]] && [[ $all_violated == 1 ]]; then
                            echo "Could not compute solution for formula : $name"
                        elif [[ $type == "EF" ]]; then
    	                    echo "FORMULA $name FALSE TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
                        else 
    	                    echo "FORMULA $name TRUE TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
                        fi
                    fi                                        
                    
                done <<< "$formulas"
            ;;
	    esac
		;;
	CTL*)
	    line=$(python3 $BK_BIN_PATH/formulizer.py ctl "$BK_EXAMINATION".xml --timeout=$TIME_CONFINEMENT --backend=sym "$F_PREFIX")
	    
        if [ $? -ne 0 ]; then
            echo "could not parse formula" 1>&2
            echo "DO_NOT_COMPETE"
            exit 0
        fi
        
        { stderr=$(eval $line 2>&1 1>&3-) ;} 3>&1
        echo "$stderr" 1>&2
        
        echo "$stderr" | grep "Got invalid permutation from boost" > /dev/null
                
        if [ $? -eq 0 ]; then
            line=$(python3 $BK_BIN_PATH/formulizer.py ctl "$BK_EXAMINATION".xml --timeout=$TIME_CONFINEMENT --backend=sym --reorder="w2W,ru,f,rs,hf" "$F_PREFIX")
	        
            if [ $? -ne 0 ]; then
                echo "could not parse formula" 1>&2
                echo "DO_NOT_COMPETE"
                exit 0
            fi
            
            { stderr=$(eval $line 2>&1 1>&3-) ;} 3>&1
            echo "$stderr" 1>&2
        fi
        
        formulas=$(echo "$stderr" | grep "ctl formula name")
        info=$(echo "$stderr" | grep "for the initial state")
                        
        while read -r line; do
            name=$(echo "$line" | cut -d' ' -f4-)
            formula=$(echo "$stderr" | grep "$line$" -A1 | grep -m1 "ctl formula formula --ctl=" | cut -d'=' -f2)
            
            echo "$info" | grep "Formula $formula does not hold for the initial state" > /dev/null
            if [ $? -eq 0 ]; then
                echo "FORMULA $name FALSE TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
            else
                echo "$info" | grep "Formula $formula holds for the initial state" > /dev/null
                if [ $? -eq 0 ]; then
                    echo "FORMULA $name TRUE TECHNIQUES DECISION_DIAGRAMS PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
                else
                    echo "Could not compute solution for formula : $name"
                fi
            fi                        
        
        done <<< "$formulas"
        
		;;
    LTL*)
        line=$(python3 $BK_BIN_PATH/formulizer.py ltl "$BK_EXAMINATION".xml --timeout=$TIME_CONFINEMENT --backend=mc "$F_PREFIX")
                
        if [ $? -ne 0 ]; then
            echo "could not parse formula" 1>&2
		    echo "DO_NOT_COMPETE"
		    exit 0
        fi
        
        { stderr=$(eval $line 2>&1 1>&3-) ;} 3>&1
        echo "$stderr" 1>&2
        info=$(echo "$stderr" | grep "ltl formula name\|Accepting cycle FOUND at depth\|total scc count\|Error: hash table full\|Error: tree leafs table full")
        formulas=$(echo "$info" | grep "ltl formula name")
                                
        while read -r line; do
                   
            name=$(echo "$line" | cut -d' ' -f4-)
            
            echo "$info" | grep "$line$" -A1 | grep 'Error: hash table full!' > /dev/null
            htf=$?

            echo "$info" | grep "$line$" -A1 | grep 'Error: tree leafs table full' > /dev/null
            tlf=$?

            if [ $htf -eq 0 -o $tlf -eq 0 ]; then
                echo "Could not compute solution for formula : $name"
            else        
                echo "$info" | grep "$line$" -A1 | grep "Accepting cycle FOUND at depth" > /dev/null
                
                if [ $? -eq 0 ]; then
        	        echo "FORMULA $name FALSE TECHNIQUES EXPLICIT PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"                
                else
                    echo "$info" | grep "$line$" -A1 | grep "total scc count" > /dev/null
                    if [ $? -eq 0 ]; then
        	            echo "FORMULA $name TRUE TECHNIQUES EXPLICIT PARALLEL_PROCESSING USE_NUPN$EXTRA_TECHNIQUES"
        	        else
                        echo "Could not compute solution for formula : $name"
        	        fi
                fi
            fi
            
        done <<< "$formulas"
        ;;    
	*)
		echo "DO_NOT_COMPETE"
		exit 0
		;;
esac

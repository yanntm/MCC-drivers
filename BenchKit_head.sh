#!/bin/bash


if [ ! -d $BK_BIN_PATH/../$BK_TOOL ] ;
then
    echo "Tool $BK_TOOL is not supported by this adapter. Please use a tool in : "
    ls */ | grep -v bin		
else 
    export BK_BIN_PATH=$BK_BIN_PATH/../$BK_TOOL/bin
    
    # does the tool support COL models or not ?
    # we put a COL file in their install folder when they do
    if [ ! -f $BK_BIN_PATH/../COL ] ; then
		grep "TRUE" iscolored > /dev/null
		# ok we need an unfold step; tool does not support COL and model is COL	
		if [ $? == 0 ]; then
			# currently a very basic unfolding is performed, with practically no reductions (STATESPACE).
			# this allows to treat all queries.
		    $BK_BIN_PATH'/itstools/its-tools' '-pnfolder' '.' '-examination' $BK_EXAMINATION '--reduce-single' 'STATESPACE'   
		    
		    # patch resulting file name, build a folder with model.pnml + examination.xml
	    	mkdir -p unf$BK_EXAMINATION
	    	mv model.STATESPACE.pnml unf$BK_EXAMINATION/model.pnml
	    	if [ -f $BK_EXAMINATION.xml ] ; then 
				mv $BK_EXAMINATION.STATESPACE.xml unf$BK_EXAMINATION/$BK_EXAMINATION.xml 
	    	fi
	    	
	    	# use this folder as run folder
	    	cd unf$BK_EXAMINATION
	    
		    # unfolding currently also degeneralize Enabling to state conditions.
		    # pretend the query was about Cardinality not Fireability
	    	if [[ $BK_EXAMINATION == *"Fireability" ]] ; then
				NEWEXAM=$(echo $BK_EXAMINATION | sed s/Fireability/Cardinality/g)
				mv $BK_EXAMINATION.xml $NEWEXAM.xml
				export BK_EXAMINATION=$NEWEXAM
	    	fi	    	    		
		fi
    fi
    # invoke the appropriate tool
    $BK_BIN_PATH/../BenchKit_head.sh
fi






#!/bin/bash


echo "Invoking MCC driver with "
echo "BK_TOOL=$BK_TOOL"
echo "BK_EXAMINATION=$BK_EXAMINATION"
echo "BK_BIN_PATH=$BK_BIN_PATH"
echo "BK_TIME_CONFINEMENT=$BK_TIME_CONFINEMENT"
echo "BK_INPUT=$BK_INPUT"

#to avoid annoying complaints about LOCALE from perl scripts
export LC_ALL=C

if [[ $BK_TOOL == *xred ]] ;
	then
		export REDUCING="TRUE"
		export BK_TOOL=$(echo $BK_TOOL | sed 's/xred//g')		
	fi

# check tool name
if [ ! -d $BK_BIN_PATH/../$BK_TOOL ] ;
then
    echo "Tool $BK_TOOL is not supported by this adapter. Please use a tool in : "
    ls */ | grep -v bin		
	echo "DO_NOT_COMPETE"
	exit 1
fi


if [ -z ${REDUCING+x} ]; 
	then 
		echo "Not applying reductions."; 
	else 
		echo "Applying reductions before tool $BK_TOOL";
		# ok looks good, call the tool.
		export BK_BIN_PATH=$BK_BIN_PATH/../reducer/bin/
		# invoke the appropriate tool
		$BK_BIN_PATH/../BenchKit_head.sh
		exit 0		 
	fi

# check support of current examination by current tool
# unfold as required
grep "TRUE" iscolored > /dev/null
if [ $? == 0 ]; then
	echo "Model is COL"
	# COL model, check if it is supported
	grep "^${BK_EXAMINATION} COL$" $BK_BIN_PATH/../$BK_TOOL/SupportedExamination.txt

	if [ $? != 0 ]; then
		# it's not directly supported, maybe PT is ok
		grep "^${BK_EXAMINATION} PT$" $BK_BIN_PATH/../$BK_TOOL/SupportedExamination.txt
		if [ $? == 0 ]; then
			# COL and PT versions of OneSafe disagree, simply unfolding won't do it
			if [ $BK_EXAMINATION == "OneSafe" ] ; then
					echo "Examination $BK_EXAMINATION for COL models is not supported by tool $BK_TOOL."
					# we can still deal with some other OneSafe properties, so CC is appropriate
					echo "CANNOT_COMPUTE"
					exit 1			
			fi
			# PT version of examination is supported we can unfold
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
		else
			# neither COL nor PT versions of this examination supported
			echo "Examination $BK_EXAMINATION is not supported by tool $BK_TOOL. Supported examinations :"
			cat $BK_BIN_PATH/../$BK_TOOL/SupportedExamination.txt
			echo "DO_NOT_COMPETE"
			exit 1
		fi	
	fi
else
	echo "Model is PT"
	
	grep "^${BK_EXAMINATION} PT$" $BK_BIN_PATH/../$BK_TOOL/SupportedExamination.txt
	if [ $? != 0 ]; then
			# examination not supported
			echo "Examination $BK_EXAMINATION is not supported by tool $BK_TOOL. Supported examinations :"
			cat $BK_BIN_PATH/../$BK_TOOL/SupportedExamination.txt
			echo "DO_NOT_COMPETE"
			exit 1				
	fi	
fi

# ok looks good, call the tool.
export BK_BIN_PATH=$BK_BIN_PATH/../$BK_TOOL/bin/
# invoke the appropriate tool
$BK_BIN_PATH/../BenchKit_head.sh




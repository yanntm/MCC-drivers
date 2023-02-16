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
    mkdir unf
    mv model.STATESPACE.pnml unf/model.pnml
	if [ -f $BK_EXAMINATION.xml ] ; then 
		mv $BK_EXAMINATION.STATESPACE.xml unf/$BK_EXAMINATION.xml 
	fi
	cd unf
fi


# pnmc may use a lot of recursion stack, this is normal.
ulimit -s 65536

$BK_BIN_PATH/pnmc.py

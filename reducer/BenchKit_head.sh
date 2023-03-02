#!/bin/bash


echo "Invoking reducer"

export BINDIR=$BK_BIN_PATH/../../itstools/
export MODEL=$(pwd)

$BINDIR/runeclipse.sh $MODEL $BK_EXAMINATION -timeout $((BK_TIME_CONFINEMENT / 10)) -rebuildPNML

# prep next tool
export BK_BIN_PATH=$BK_BIN_PATH/../../$BK_TOOL/bin/

if [ -f $BK_EXAMINATION.solved ]
then 
	echo "ITS solved all properties within timeout"
	exit 0
fi

if [ -f model.sr.pnml ] 
then
	echo "There are residual formulas that ITS could not solve within timeout"
	mkdir $$
	cp $BK_EXAMINATION.sr.xml $$/$BK_EXAMINATION.xml
	cp model.sr.pnml $$/model.pnml
	cd $$

	bash $BK_BIN_PATH/../BenchKit_head.sh

	cd ..
else
	bash $BK_BIN_PATH/../BenchKit_head.sh
fi

#!/bin/bash


echo "Invoking reducer"

export BINDIR=$BK_BIN_PATH/../../itstools/
export MODEL=$(pwd)

$BINDIR/runeclipse.sh $MODEL $BK_EXAMINATION -timeout $BK_TIME_CONFINEMENT -rebuildPNML

# prep next tool
export BK_BIN_PATH=$BK_BIN_PATH/../../$BK_TOOL/bin

if [ -f model.sr.pnml ] 
then
	# there are residual problems
	mkdir $$
	cp $BK_EXAMINATION.sr.xml $$/$BK_EXAMINATION.xml
	cp model.sr.pnml $$/model.pnml
	cd $$

	bash $BK_BIN_PATH/../BenchKit_head.sh

	cd ..
else
	bash $BK_BIN_PATH/../BenchKit_head.sh
fi

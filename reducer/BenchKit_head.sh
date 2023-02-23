#!/bin/bash


echo "Invoking reducer"

export BINDIR=$BK_BIN_PATH/../../itstools/bin/
export MODEL=$(pwd)

$BINDIR/../runeclipse.sh $MODEL $BK_EXAMINATION -timeout $BK_TIME_CONFINEMENT -rebuildPNML

if [ -f model.sr.pnml ] 
then
	mkdir $$
	cp $BK_EXAMINATION.sr.xml $$/$BK_EXAMINATION.xml
	cp model.sr.pnml $$/model.pnml
	cd $$

	export BK_BIN_PATH=$BK_BIN_PATH/../../$BK_TOOL/bin
	bash $BK_BIN_PATH/../BenchKit_head.sh

	cd ..
fi

#! /bin/bash

# Install the PetriSpot binary. By default the Linux build published by the
# PetriSpot CI is downloaded; set PETRISPOT_BIN to the path of a local build
# (e.g. PetriSpot/build/petri64) to install that one instead.

set -x
set -e

mkdir -p bin/

if [ -n "$PETRISPOT_BIN" ] ; then
	cp "$PETRISPOT_BIN" bin/petri64
else
	wget --progress=dot:mega https://github.com/yanntm/PetriSpot/raw/Inv-Linux/petri64 -O bin/petri64
fi
chmod a+x bin/petri64
chmod a+x BenchKit_head.sh

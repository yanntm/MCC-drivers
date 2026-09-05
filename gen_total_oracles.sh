#! /bin/bash

# Bogus oracles for the total examinations: one "?" per transition
# (QuasiLivenessAll) or per place (StableMarkingAll, UpperBoundsAll), so that
# run_test.pl accepts any verdict and only reports the atoms left unanswered.
# Replace a "?" with a verdict once one is trusted.
#   ./gen_total_oracles.sh Peterson-PT-5 ...   # given instances
#   ./gen_total_oracles.sh                     # every P/T instance in INPUTS/
# Counts are read from model.pnml inside INPUTS/<instance>.tgz. P/T only.

set -e
mkdir -p oracle

if [ $# -eq 0 ] ; then
	set -- $(ls INPUTS/*-PT-*.tgz | sed 's|INPUTS/||; s|\.tgz$||')
fi

for m in "$@" ; do
	tgz=INPUTS/$m.tgz
	if [ ! -f $tgz ] ; then
		wget -q https://github.com/yanntm/pnmcc-models-2026/blob/gh-pages/INPUTS/$m.tgz?raw=true -O $tgz
	fi
	counts=$(tar xzOf $tgz --wildcards '*/model.pnml' | grep -o -E '<(place|transition) ' | sort | uniq -c)
	P=$(echo "$counts" | awk '/place/ {print $1}')
	T=$(echo "$counts" | awk '/transition/ {print $1}')
	P=${P:-0} ; T=${T:-0}

	{ echo "$m QuasiLivenessAll" ; seq 0 $((T-1)) | sed 's/^/QLIVE t/; s/$/ ?/' ; } > oracle/$m-QLA.out
	{ echo "$m StableMarkingAll" ; seq 0 $((P-1)) | sed 's/^/STABLE p/; s/$/ ?/' ; } > oracle/$m-SMA.out
	{ echo "$m UpperBoundsAll" ; seq 0 $((P-1)) | sed 's/^/BOUND p/; s/$/ ?/' ; } > oracle/$m-UBA.out
	echo "$m places=$P transitions=$T"
done

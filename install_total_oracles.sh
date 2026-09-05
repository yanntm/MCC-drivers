#! /bin/bash

# The oracles of the total examinations (QuasiLivenessAll, StableMarkingAll,
# UpperBoundsAll : one "?" per transition or place, see pnmcc-models-2026) are
# too large to commit next to the consensus oracles. Fetch them and unpack
# into oracle/ ; the files are ignored by git.

set -x
set -e

if [ ! -f oracle-total.tar.gz ] ; then
	wget --progress=dot:mega https://yanntm.github.io/pnmcc-models-2026/oracle-total.tar.gz
fi

tar xzf oracle-total.tar.gz

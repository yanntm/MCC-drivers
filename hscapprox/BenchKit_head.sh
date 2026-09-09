#!/bin/bash
# libHSC with the over-approximation first on the reachability examinations:
# the hsc driver (../hsc) under HSC_APPROX=1, so the two settings run side by
# side as two tools (BK_TOOL=hsc, BK_TOOL=hscapprox) without mixing logs.
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export HSC_APPROX=1
exec "$DIR/../hsc/BenchKit_head.sh" "$@"

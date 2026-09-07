#! /bin/bash
# libHSC in the MCC harness: a portfolio of shape and order configurations run in
# parallel on the examination, the first answer wins. hsc is single threaded and
# no configuration dominates (libHSC_in_MCC.md in PetriSpot): the NUPN tree as
# is, FORCE reordering, Louvain decomposition, Louvain then FORCE.
# Runs in the model folder (model.pnml). Prints CANNOT_COMPUTE when no
# configuration answers within the confinement.
echo "libHSC driver: BK_EXAMINATION=$BK_EXAMINATION BK_INPUT=$BK_INPUT BK_TIME_CONFINEMENT=$BK_TIME_CONFINEMENT"
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN=$DIR/bin
MARGIN=${HSC_MARGIN:-5}
if [ -z "$BK_TIME_CONFINEMENT" ] ; then BK_TIME_CONFINEMENT=3600 ; fi
TOTAL=$((BK_TIME_CONFINEMENT - MARGIN))
if [ "$TOTAL" -le 0 ] ; then TOTAL=1 ; fi
if [ -n "$BK_MEMORY_CONFINEMENT" ] ; then
	ulimit -v $(( (BK_MEMORY_CONFINEMENT - 256) * 1024 ))
fi
if [ ! -x "$BIN/hsc" ] || [ ! -x "$BIN/hsc-mcc" ] || [ ! -x "$BIN/nupn2hsc" ] ; then
	echo "libHSC binaries not found in $BIN (run install.sh)"
	echo "CANNOT_COMPUTE"
	exit 1
fi
case "$BK_EXAMINATION" in
	StateSpace) QUERY='(states R)' ; PATTERN='^STATE_SPACE ' ;;
	OneSafe) QUERY='(max-value R)' ; PATTERN='^R max-value ' ;;
	*)
		echo "Examination $BK_EXAMINATION is not supported by libHSC."
		echo "DO_NOT_COMPETE"
		exit 0
		;;
esac
WORK=$(mktemp -d "${TMPDIR:-/tmp}/hsc-mcc.XXXXXX")
trap 'kill $(jobs -p) 2> /dev/null; rm -rf "$WORK"' EXIT
# the model once, its queries stripped; every configuration reads it
"$BIN/nupn2hsc" model.pnml 2> "$WORK/import.err" | sed '/^(reach /,$d' > "$WORK/model.hsc"
if [ ! -s "$WORK/model.hsc" ] ; then
	echo "import failed:" ; cat "$WORK/import.err"
	echo "CANNOT_COMPUTE"
	exit 1
fi
declare -A CONF=(
	[nupn]=""
	[force]="-e (reorder-force)"
	[louvain]="-e (decompose-louvain)"
	[louvain-force]="-e (decompose-louvain) -e (reorder-force)"
)
for c in "${!CONF[@]}" ; do
	( timeout "$TOTAL" "$BIN/hsc" "$WORK/model.hsc" ${CONF[$c]} -e '(reach R saturate)' -e "$QUERY" > "$WORK/$c.out" 2> "$WORK/$c.err" ; echo $? > "$WORK/$c.status" ) &
done
# the first configuration with an answer wins; the others are stopped
WINNER=""
while [ -n "$(jobs -p)" ] ; do
	for c in "${!CONF[@]}" ; do
		if [ -f "$WORK/$c.status" ] && grep -q "$PATTERN" "$WORK/$c.out" ; then WINNER=$c ; break 2 ; fi
	done
	if ! wait -n 2> /dev/null ; then break ; fi
done
for c in "${!CONF[@]}" ; do
	if [ -z "$WINNER" ] && [ -f "$WORK/$c.status" ] && grep -q "$PATTERN" "$WORK/$c.out" ; then WINNER=$c ; fi
done
kill $(jobs -p) 2> /dev/null
if [ -z "$WINNER" ] ; then
	echo "no configuration answered within $TOTAL s"
	for c in "${!CONF[@]}" ; do echo "== $c: status $(cat "$WORK/$c.status" 2> /dev/null)" ; tail -3 "$WORK/$c.err" ; done
	echo "CANNOT_COMPUTE"
	exit 0
fi
echo "answered by configuration $WINNER"
grep -v '^STATE_SPACE\|^R max-value' "$WORK/$WINNER.out"
case "$BK_EXAMINATION" in
	StateSpace)
		# STATES is a double in the surface: exact only below 2^53
		grep '^STATE_SPACE ' "$WORK/$WINNER.out"
		;;
	OneSafe)
		MX=$(grep -o 'max-value [0-9]*' "$WORK/$WINNER.out" | head -1 | awk '{print $2}')
		if [ "$MX" -le 1 ] ; then V=TRUE ; else V=FALSE ; fi
		echo "FORMULA OneSafe $V TECHNIQUES DECISION_DIAGRAMS SATURATION"
		;;
esac
exit 0

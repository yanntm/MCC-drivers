#! /bin/bash
# libHSC in the MCC harness, on hsc-pn (libHSC tools/README.md): a portfolio of
# shape and order configurations run in parallel on the examination, their
# FORMULA lines merged, the first complete configuration stopping the others.
# hsc-pn is single threaded and no configuration dominates (libHSC_in_MCC.md in
# PetriSpot): the NUPN tree as is, FORCE reordering, Louvain, Louvain + FORCE.
# Runs in the model folder (model.pnml, <Examination>.xml). Prints
# CANNOT_COMPUTE for what no configuration answered within the confinement.
echo "libHSC driver: BK_EXAMINATION=$BK_EXAMINATION BK_INPUT=$BK_INPUT BK_TIME_CONFINEMENT=$BK_TIME_CONFINEMENT"
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN=$DIR/bin
MARGIN=${HSC_MARGIN:-5}
if [ -z "$BK_TIME_CONFINEMENT" ] ; then BK_TIME_CONFINEMENT=3600 ; fi
TOTAL=$((BK_TIME_CONFINEMENT - MARGIN))
if [ "$TOTAL" -le 0 ] ; then TOTAL=1 ; fi
# the configurations to run (HSC_CONFS, space separated; default all four); the
# memory confinement is shared by those running side by side, each gets its
# share so the portfolio cannot exceed the limit as a whole
declare -A CONF=(
	[nupn]="--shape nupn"
	[force]="--shape nupn --force"
	[louvain]="--shape louvain"
	[louvain-force]="--shape louvain --force"
)
CONFS=(${HSC_CONFS:-nupn force louvain louvain-force})
for c in "${CONFS[@]}" ; do
	if [ -z "${CONF[$c]}" ] ; then echo "unknown configuration $c (HSC_CONFS)" ; echo "CANNOT_COMPUTE" ; exit 1 ; fi
done
if [ -n "$BK_MEMORY_CONFINEMENT" ] ; then
	ulimit -v $(( (BK_MEMORY_CONFINEMENT - 256) * 1024 / ${#CONFS[@]} ))
fi
if [ ! -x "$BIN/hsc-pn" ] ; then
	echo "libHSC binaries not found in $BIN (run install.sh)"
	echo "CANNOT_COMPUTE"
	exit 1
fi
# the question, the number of answers expected, and the line prefix of an answer
case "$BK_EXAMINATION" in
	ReachabilityCardinality|ReachabilityFireability|UpperBounds)
		if [ ! -f "$BK_EXAMINATION.xml" ] ; then echo "Property file $BK_EXAMINATION.xml not found." ; echo "CANNOT_COMPUTE" ; exit 1 ; fi
		QUERY="--props $BK_EXAMINATION.xml" ; EXPECTED=$(grep -c "<property>" "$BK_EXAMINATION.xml") ; PREFIX='^FORMULA '
		# HSC_APPROX=1: the over-approximation first (the invariant set, the
		# properties it refutes, a backward search inside it), then the fixpoint
		# under the remaining budget (libHSC tools/README.md, --approx)
		if [ "${HSC_APPROX:-0}" = "1" ] && [ "$BK_EXAMINATION" != "UpperBounds" ] ; then
			QUERY="$QUERY --approx 5 --approx-units --approx-back 50 --approx-back-time 2 --totalTime $TOTAL"
		fi ;;
	CTLCardinality|CTLFireability)
		# the CTL checker (libHSC include/hsc/ctl/): the tool runs the formulas in
		# rounds of growing per-property budget under --totalTime, so the whole
		# confinement is handed to it and the merge keeps what each configuration
		# answered
		if [ ! -f "$BK_EXAMINATION.xml" ] ; then echo "Property file $BK_EXAMINATION.xml not found." ; echo "CANNOT_COMPUTE" ; exit 1 ; fi
		QUERY="--props $BK_EXAMINATION.xml --totalTime $TOTAL" ; EXPECTED=$(grep -c "<property>" "$BK_EXAMINATION.xml") ; PREFIX='^FORMULA ' ;;
	ReachabilityDeadlock) QUERY="--deadlock ReachabilityDeadlock" ; EXPECTED=1 ; PREFIX='^FORMULA ' ;;
	StateSpace) QUERY="--states" ; EXPECTED=4 ; PREFIX='^STATE_SPACE ' ;;
	OneSafe) QUERY="--max-tokens" ; EXPECTED=1 ; PREFIX='^STATE_SPACE ' ;;
	*)
		echo "Examination $BK_EXAMINATION is not supported by libHSC."
		echo "DO_NOT_COMPETE"
		exit 0
		;;
esac
# A coloured input reaches us unfolded: the harness runs ITS-Tools on it because
# we declare P/T only, and that unfolder fuses symmetric bindings without
# reporting their multiplicity. The unfolded net has the same states but fewer
# arcs than the coloured semantics, so TRANSITIONS would be an undercount: we
# do not answer it there (the other three values are unaffected).
COLOURED=""
if [ "$(head -1 iscolored 2>/dev/null)" = "TRUE" ] ; then
	COLOURED=1
	if [ "$BK_EXAMINATION" = "StateSpace" ] ; then EXPECTED=3 ; fi
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/hsc-mcc.XXXXXX")
trap 'kill $(jobs -p) 2> /dev/null; rm -rf "$WORK"' EXIT
for c in "${CONFS[@]}" ; do
	( timeout "$TOTAL" "$BIN/hsc-pn" -i model.pnml ${CONF[$c]} $QUERY -q > "$WORK/$c.out" 2> "$WORK/$c.err" ; echo $? > "$WORK/$c.status" ) &
done
# stop as soon as one configuration has every answer; otherwise wait for all
complete() { [ "$(grep -c "$PREFIX" "$WORK/$1.out" 2> /dev/null)" -ge "$EXPECTED" ] ; }
while [ -n "$(jobs -p)" ] ; do
	for c in "${CONFS[@]}" ; do complete "$c" && break 2 ; done
	sleep 0.2
	if ! wait -n 2> /dev/null ; then break ; fi
done
kill $(jobs -p) 2> /dev/null
# merge: for every answer line (by its second word), the first configuration that has it
declare -A SEEN
for c in "${CONFS[@]}" ; do
	while read -r line ; do
		key=$(echo "$line" | cut -d' ' -f2)
		if [ -n "$COLOURED" ] && [ "$key" = "TRANSITIONS" ] ; then continue ; fi
		# the attribution goes to stdout: the harness ignores lines that are not
		# answers, and the collected logs keep only stdout, so this is where a
		# campaign can see which shape and order answered
		if [ -z "${SEEN[$key]}" ] ; then SEEN[$key]=$c ; echo "answered $key by configuration $c" ; MERGED+=("$line") ; fi
	done < <(grep "$PREFIX" "$WORK/$c.out" 2> /dev/null)
done
for c in "${CONFS[@]}" ; do echo "== $c: exit $(cat "$WORK/$c.status" 2> /dev/null), $(grep -c "$PREFIX" "$WORK/$c.out" 2> /dev/null) answers" ; tail -2 "$WORK/$c.err" ; done
case "$BK_EXAMINATION" in
	OneSafe)
		MX=$(printf '%s\n' "${MERGED[@]}" | grep -o 'MAX_TOKEN_IN_PLACE [0-9]*' | head -1 | awk '{print $2}')
		if [ -z "$MX" ] ; then echo "CANNOT_COMPUTE" ; exit 0 ; fi
		if [ "$MX" -le 1 ] ; then V=TRUE ; else V=FALSE ; fi
		echo "FORMULA OneSafe $V TECHNIQUES DECISION_DIAGRAMS SATURATION"
		;;
	*)
		printf '%s\n' "${MERGED[@]}" | grep "$PREFIX"
		if [ "${#MERGED[@]}" -lt "$EXPECTED" ] ; then echo "answered ${#MERGED[@]} of $EXPECTED" ; echo "CANNOT_COMPUTE" ; fi
		;;
esac
exit 0

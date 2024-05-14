#!/bin/bash

##############################################################
# BK_TOOL 				that names the invoked tool (useful when you provide several 
# 						tool variants in the same virtual machine),
# BK_TIME_CONFINEMENT 	that shows the time confinement in seconds,
# BK_MEMORY_CONFINEMENT that shows the memory confinement in Mbytes.
# BK_BIN_PATH 			that the absolute path of the directory where BenchKit 
# 						suggests you to put binaries files of your tool.
# echo "BK_TOOL               = ${BK_TOOL}"
# echo "BK_TIME_CONFINEMENT   = ${BK_TIME_CONFINEMENT}"
# echo "BK_MEMORY_CONFINEMENT = ${BK_MEMORY_CONFINEMENT}"
# echo "BK_BIN_PATH           = ${BK_BIN_PATH}"
# echo "BK_EXAMINATION        = ${BK_EXAMINATION}"
# echo "BK_INPUT              = ${BK_INPUT}"
# echo $(pwd)
# exit 0


##############################################################
export MCC=1
# CRT_DIR=$(basename $(pwd))
# MODEL_NAME=$(echo "$BK_INPUT" | cut -d '-' -f 1)
# MODEL_TYPE=$(echo "$BK_INPUT "| cut -d '-' -f 2)
# MODEL_INST=$(echo "$BK_INPUT" | cut -d '-' -f 3)

# Model directory (where temporary files will be created)
MDIR=$(pwd)

# Directory of GreatSPN binaries
GREATSPN_ROOT=$BK_BIN_PATH/../greatspn/lib/app/portable_greatspn
GREATSPN_BIN=${GREATSPN_ROOT}/bin
EDITOR_DIST=${GREATSPN_ROOT}/..

EDITOR_CLASSPATH=${EDITOR_DIST}/Editor.jar
for JAR in ${EDITOR_DIST}/lib/*.jar ; do
	EDITOR_CLASSPATH=${EDITOR_CLASSPATH}:${JAR}
done

# Add meddly to the Library Path, so that RGMEDD5 will link to it
export LD_LIBRARY_PATH=${GREATSPN_ROOT}/lib:${LD_LIBRARY_PATH}
export PATH=${GREATSPN_BIN}:${PATH}
export MCCFORMULACONV=${BK_BIN_PATH}/MccCtlConv/MccCtlConv.jar
LINE="----------------------------------------------------------------------"

echo ${LINE}
echo "    GreatSPN-meddly tool, MCC 2023"
echo ${LINE}
echo
echo "Running ${BK_INPUT}"
echo

IS_COLORED=""
UNFOLDING_MAP=""
IS_NUPN=""

MODEL=${MDIR}/model

# convert GlobalProperty examination label to the corresponding keyword
function GlobalProperty_To_Keyword() {
	case "$1" in
		'ReachabilityDeadlock') echo 'HAS_DEADLOCK' ;;
		'QuasiLiveness')        echo 'QUASI_LIVENESS' ;;
		'StableMarking')        echo 'STABLE_MARKING' ;;
		'Liveness')             echo 'LIVENESS' ;;
		'OneSafe')              echo 'ONESAFE' ;;
	esac
}

# Parallel execution control parameters
PARALLEL_SP="-parallel-sp 4 3600 4 4096"
PARALLEL_MC="-parallel-mc     60 4 4096"
PARALLEL_VO="-parallel-vo        6"

#=============================================================================
# Examination analysis: should we compete? should we process a formula file?
#=============================================================================
case ${BK_EXAMINATION} in
	StateSpace)
		;;

	UpperBounds|ReachabilityFireability|ReachabilityCardinality|CTL*)
		FORMULA_XML=${BK_EXAMINATION}.xml
		FORMULA_GREATSPN=${BK_EXAMINATION}.gctl
		FORMULA_FLAGS="-C -f ${FORMULA_GREATSPN}"
		CONV_LANG="CTL"
		;;

	LTL*)
		FORMULA_XML=${BK_EXAMINATION}.xml
		FORMULA_GREATSPN=${BK_EXAMINATION}.gctl
		FORMULA_FLAGS="-C -f ${FORMULA_GREATSPN}"
		CONV_LANG="CTLSTAR"
		;;

	# GlobalProperties: generate query file
	ReachabilityDeadlock|QuasiLiveness|StableMarking|Liveness|OneSafe)
		FORMULA_GREATSPN=${BK_EXAMINATION}.gctl
		echo "FORMULA: ${BK_EXAMINATION}" > ${FORMULA_GREATSPN}
		echo "LANGUAGE: CTLSTAR" >> ${FORMULA_GREATSPN}
		echo `GlobalProperty_To_Keyword ${BK_EXAMINATION}` >> ${FORMULA_GREATSPN}
		FORMULA_FLAGS="-C -f ${FORMULA_GREATSPN}"
		PARALLEL_MC=""
		;;

	*)
		echo 'DO_NOT_COMPETE'
		exit
		;;
esac

# decide the saturation strategy that will be used
case ${BK_EXAMINATION} in
	ReachabilityFireability|ReachabilityCardinality|CTL*|LTL*)
		FORMULA_FLAGS="${FORMULA_FLAGS} -sat-event" # -impl-next
		;;

	ReachabilityDeadlock|Liveness)
		FORMULA_FLAGS="${FORMULA_FLAGS} -sat-event" # -impl-next
		;;
esac

#=============================================================================
# Is this a PT or a COL model? 
#=============================================================================
if [[ ! -f ${MDIR}/iscolored ]] ; then
	echo "Missing ${MDIR}/iscolored file."
	exit
fi
if [[ `cat ${MDIR}/iscolored` == "TRUE" ]] ; then
	IS_COLORED="1"
	UNFOLDING_MAP="-unfolding-map model.unfmap"
fi

#=============================================================================
# Determine NUPN availability (from the pnml file)
#=============================================================================
if [[ ! -z `cat ${MDIR}/model.pnml | grep '<toolspecific' | grep 'nupn'` ]]; then
	IS_NUPN="1"
fi

#=============================================================================
# PNML -> net/def conversion
#=============================================================================
if [[ ! -f model.def ]] ; then
	# The Java converter supports colored and NUPN models, while GSOL
	# supports only PT models (but it is much faster).
	echo "IS_COLORED=${IS_COLORED}"
	echo "IS_NUPN=${IS_NUPN}"
	echo
	if [[ $IS_COLORED || $IS_NUPN ]] ; then
		# Use Java unfolding/converter
		java -mx14000m -cp ${EDITOR_CLASSPATH} \
			editor.cli.UnfoldingCommand ${MODEL} -name-map -short-names
	else
		# Use GSOL converter. PNML ids are compulsory for models where textual ids
		# are not unique among places and transitions (i.e. Lamport)
		${GREATSPN_BIN}/GSOL -use-pnml-ids ${MODEL}.pnml -export-greatspn ${MODEL}
	fi
fi

if [[ ! -f ${MODEL}.def ]] ; then
	echo "Cannot convert PNML file into net/def format."
	rm -f ${MODEL}.net ${MODEL}.def
	exit
fi

if [[ ! -f ${MODEL}.id2name ]] ; then
	echo "Missing id2name file."
	rm -f ${MODEL}.net ${MODEL}.def
	exit
fi

#=============================================================================
# Structural analysis
#=============================================================================

#Stage 1
if [[ ! -e ${MODEL}.pin || ! -e ${MODEL}.bnd || ${MODEL}.net -nt ${MODEL}.pin || ${MODEL}.net -nt ${MODEL}.bnd ]] ; then
	# Determine P-flow basis, P-semiflows and place bounds
	${GREATSPN_BIN}/DSPN-Tool -nnv -load ${MODEL} -pbasis -detect-exp -psfl -bnd   > /dev/null 2>&1
fi

# Stage 2
if [[ ! -f ${MODEL}.ilpbnd || ${MODEL}.net -nt ${MODEL}.ilpbnd ]] ; then
	# Determine place bounds using ILP
	${GREATSPN_BIN}/DSPN-Tool -nnv -load ${MODEL} -load-bnd -timeout 5 -ilp-bnd   > /dev/null 2>&1
	if [[ $? != 0 ]] ; then
		rm -f ${MODEL}.ilpbnd
	fi
fi

#=============================================================================
# Convert CTL formulas
#=============================================================================

if [[ ! -z ${FORMULA_XML}  ]] ; then
	if [[ ! -f ${FORMULA_GREATSPN} || ${MODEL}.net -nt ${FORMULA_GREATSPN} ]] ; then
		# Convert XML formulas in the GreatSPN syntax
		java -Dcom.sun.xml.bind.v2.bytecode.ClassTailor.noOptimize=1 \
		     -jar ${MCCFORMULACONV} ${FORMULA_XML} -l ${CONV_LANG} \
			 -name-map model.id2name ${UNFOLDING_MAP} > ${FORMULA_GREATSPN}
		# cat ${FORMULA_GREATSPN}
	fi
fi

#=============================================================================
# Launch GreatSPN-meddly
#=============================================================================

MEDDLY_CACHE="67108864"

# Increase stack size (for large models with thousands of places)
ulimit -s 32768

echo ${LINE}

# start RGMEDD5 
${GREATSPN_BIN}/RGMEDD5 ${MODEL} \
						-h ${MEDDLY_CACHE} \
						${FORMULA_FLAGS} \
						${PARALLEL_SP} \
						${PARALLEL_MC} \
						${PARALLEL_VO}

echo "EXITCODE: $?"
echo ${LINE}

#=============================================================================



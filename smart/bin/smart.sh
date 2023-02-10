#!/bin/bash

BIN_DIR=$HOME/BenchKit/bin
PARSER=

#SMART_SS=${BIN_DIR}/main/smart
#SMART=${BIN_DIR}/smart
SMART=${BIN_DIR}/rem_exec/smart

INPUT_PNML=model.pnml

# Used as the extra argument
INPUT_UPPERBOUNDS=UpperBounds.xml

# INPUT_REACHABILITYDEADLOCK=ReachabilityDeadlock.xml
# INPUT_QUASILIVENESS=QuasiLiveness.xml
# INPUT_LIVENESS=Liveness.xml
# INPUT_ONESAFE=One-Safe.xml
# INPUT_STABLEMARKING=StableMarking.xml

INPUT_REACHABILITYFIREABILITY=ReachabilityFireability.xml
INPUT_REACHABILITYCARDINALITY=ReachabilityCardinality.xml

INPUT_CTLFIREABILITY=CTLFireability.xml
INPUT_CTLCARDINALITY=CTLCardinality.xml

# File produced by the parser
INPUT_SM=model.sm

IS_COLORED=iscolored
#SETTINGS_FILE=""

if [[ `grep TRUE $IS_COLORED` ]]
then
  echo "DO_NOT_COMPETE"
else
  MODEL_NAME=$(echo "$BK_INPUT" | cut -d '-' -f 1)
  MODEL_TYPE=$(echo "$BK_INPUT "| cut -d '-' -f 2)
  MODEL_INST=$(echo "$BK_INPUT" | cut -d '-' -f 3)

  # Choose the parser and the extra argument
  case "$1" in
    StateSpace)
      SMART=${BIN_DIR}/main/smart 
      PARSER=${BIN_DIR}/parser/StateSpaceParse.jar
      INPUT_EXTRA=
      ;;
    UpperBounds)
      SMART=${BIN_DIR}/upper_bound/smart
      PARSER=${BIN_DIR}/parser/UpperBoundParse.jar
      INPUT_EXTRA=${INPUT_UPPERBOUNDS}
      ;;
    ReachabilityDeadlock)
      PARSER=${BIN_DIR}/parser/DeadlockParse.jar
      INPUT_EXTRA=
      ;;
    Liveness)
      PARSER=${BIN_DIR}/parser/Liveness.jar
      INPUT_EXTRA=
      ;;
    QuasiLiveness)
      PARSER=${BIN_DIR}/parser/QuasiLive.jar
      INPUT_EXTRA=
      ;;
   StableMarking)
      PARSER=${BIN_DIR}/parser/StableMarking.jar
      INPUT_EXTRA=
      ;;
   OneSafe)
      PARSER=${BIN_DIR}/parser/OneSafe.jar
      INPUT_EXTRA=
      ;;
    ReachabilityFireability)
      PARSER=${BIN_DIR}/parser/Fireability.jar
      INPUT_EXTRA=${INPUT_REACHABILITYFIREABILITY}
      ;;
    ReachabilityCardinality)
      PARSER=${BIN_DIR}/parser/Cardinality.jar
      INPUT_EXTRA=${INPUT_REACHABILITYCARDINALITY}
      ;;
   CTLFireability)
      PARSER=${BIN_DIR}/parser/CTLFire.jar
      INPUT_EXTRA=${INPUT_CTLFIREABILITY}
      ;;
    CTLCardinality)
      PARSER=${BIN_DIR}/parser/CTLCard.jar
      INPUT_EXTRA=${INPUT_CTLCARDINALITY}
      ;;
    *)
      echo "DO_NOT_COMPETE"
      ;;
  esac

  echo "======================================================"
  echo "========== this is Smart for the MCC'2018 ============"
  echo "======================================================"
  echo "Running $MODEL_NAME ($MODEL_TYPE), instance $MODEL_INST"
  echo "Examination $1"
  echo "Parser $PARSER"
  echo "Model checker $SMART"
  echo
  
##
##  result=$(grep -F "$MODEL_NAME" KnownModelAlpha.txt)
  
##  if [ -n "$result" ]
##  then
##	SETTINGS_FILE=settings.txt
##	echo "$(echo "$result" | cut -d ' ' -f 2)","$(echo "$result" | cut -d ' ' -f 3)" > "$SETTINGS_FILE"
##  fi
##
  
  java -jar ${PARSER} ${INPUT_PNML} ${INPUT_EXTRA}
  ${SMART} ${INPUT_SM}
  #rm ${INPUT_SM}
  ##rm ${SETTINGS_FILE}
fi

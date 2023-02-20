echo "starting LoLA"
echo "BK_INPUT $BK_INPUT"
echo "BK_EXAMINATION: $BK_EXAMINATION"
export DIR=$(pwd)
export BIN_DIR=$BK_BIN_PATH
echo "bin directory: $BIN_DIR"
echo "current directory: $DIR"

if [ "$BK_INPUT" == "GPPP-PT-C0010N1000000000" ] 
then 
    echo "DO NOT COMPETE"
elif [ "$BK_EXAMINATION" == "StateSpace" ]
then
    echo "DO NOT COMPETE"
elif [ "$BK_EXAMINATION" == "CTLCardinality" ]
then
    lola --conf=$BIN_DIR/configfiles/ctlcardinalityconf --formula=$DIR/CTLCardinality.xml --verdictfile=$DIR/GenericPropertiesVerdict.xml $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "CTLFireability" ]
then
    echo "CTLFireability"
    lola --conf=$BIN_DIR/configfiles/ctlfireabilityconf  --formula=$DIR/CTLFireability.xml --verdictfile=$DIR/GenericPropertiesVerdict.xml $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "LTLCardinality" ]
then
    echo "LTLCardinality"
    lola --conf=$BIN_DIR/configfiles/ltlcardinalityconf  --formula=$DIR/LTLCardinality.xml --verdictfile=$DIR/GenericPropertiesVerdict.xml $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "LTLFireability" ]
then
    echo "LTLFireability"
    lola --conf=$BIN_DIR/configfiles/ltlfireabilityconf  --formula=$DIR/LTLFireability.xml --verdictfile=$DIR/GenericPropertiesVerdict.xml $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "ReachabilityCardinality" ]
then
    echo "ReachabilityCardinality"
    lola --conf=$BIN_DIR/configfiles/reachabilitycardinalityconf  --formula=$DIR/ReachabilityCardinality.xml --verdictfile=$DIR/GenericPropertiesVerdict.xml $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "ReachabilityFireability" ]
then
    echo "ReachabilityFireability"
    lola --conf=$BIN_DIR/configfiles/reachabilityfireabilityconf  --formula=$DIR/ReachabilityFireability.xml --verdictfile=$DIR/GenericPropertiesVerdict.xml $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "ReachabilityDeadlock" ]
then
    echo "GlobalProperty: ReachabilityDeadlock"
    lola --conf=$BIN_DIR/configfiles/globalconf  --check=deadlockfreedom $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "QuasiLiveness" ]
then
    echo "GlobalProperty: QuasiLiveness"
    lola --conf=$BIN_DIR/configfiles/globalconf  --check=QuasiLiveness $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "StableMarking" ]
then
    echo "GlobalProperty: StableMarking"
    lola --conf=$BIN_DIR/configfiles/globalconf  --check=StableMarking $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "Liveness" ]
then
    echo "GlobalProperty: Liveness"
    lola --conf=$BIN_DIR/configfiles/globalconf  --check=Liveness $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "OneSafe" ]
then
    echo "GlobalProperty: OneSafe"
    lola --conf=$BIN_DIR/configfiles/globalconf  --check=OneSafe $DIR/model.pnml
elif [ "$BK_EXAMINATION" == "UpperBounds" ]
then
    echo "Upper Bounds"
    lola --conf=$BIN_DIR/configfiles/upperboundsconf  --formula=$DIR/UpperBounds.xml $DIR/model.pnml
fi

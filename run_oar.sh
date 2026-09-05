#! /bin/bash

# Submit one OAR job per oracle file: one model instance, one examination.
#   ./run_oar.sh 'oracle/AirplaneLD-*.out'
# The glob is quoted so it is expanded here, not by the caller's shell.
#
# Results sort themselves: OAR writes OAR.<jobid>.stdout into the directory the
# job was submitted from, so we submit from a folder named after the
# examination suffix (RC, RF, RD, LTLF, OS, ...).
#
# The default runner is ./runatest.sh, which unpacks each model once into
# INPUTS/<model>/ and leaves it there for later jobs to reuse. A run does not
# write into that folder, so concurrent jobs on the same instance share it
# safely -- except under the xred tools, where the reducer does write there.
# For those, RUNATEST=./runatest_cluster.sh gives each job a $$ suffixed copy.
# Seed the folders with one examination first, so the unpacking happens once
# and concurrent jobs never race to untar the same archive.

set -e

SELECT=${1:-oracle/AirplaneLD-*.out}
TREE=$(cd "$(dirname "$0")" && pwd)
TIMEOUT=${TIMEOUT:-300}
WALLTIME=${WALLTIME:-0:05:20}
CORES=${CORES:-4}
HOSTS=${HOSTS:-tall%}
RUNATEST=${RUNATEST:-./runatest.sh}
export BK_TOOL=${BK_TOOL:-itstools}

njobs=0
for i in $SELECT ; do
	DIR=$(echo $i | perl -pe 's/.*\-(\w+)\.out/\1/g')
	mkdir -p $DIR
	cd $DIR
	oarsub -l "/nodes=1/core=$CORES,walltime=$WALLTIME" -p "(host like '$HOSTS')" \
	  "uname -a ; cd $TREE && BK_TOOL=$BK_TOOL RUNATEST=$RUNATEST ./run_test.pl $i -t $TIMEOUT ; exit" \
	  > /dev/null
	cd ..
	njobs=$((njobs + 1))
done
echo "submitted $njobs jobs, tool $BK_TOOL, runner $RUNATEST, timeout ${TIMEOUT}s, walltime $WALLTIME, $CORES cores, hosts $HOSTS"

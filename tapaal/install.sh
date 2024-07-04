#! /bin/bash

set -x
set -e

mkdir -p bin/

# TODO : use TAPAAL/verifypn when the fork is merged.
export DLURL=https://github.com/yanntm/verifypn/raw/linux/verifypn-mcc-linux64 
wget --progress=dot:mega $DLURL -O bin/verifypn
chmod a+x bin/verifypn

chmod a+x bin/tapaal.sh
chmod a+x BenchKit_head.sh

mkdir -p bin/tmp/

  

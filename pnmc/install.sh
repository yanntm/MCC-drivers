#! /bin/bash

set -x
set -e

cd bin

# -O so that re-running this script overwrites the binary instead of
# accumulating pnmc.1, pnmc.2, ... next to it.
wget --progress=dot:mega https://github.com/yanntm/pnmc/raw/gh-pages/pnmc -O pnmc
chmod a+x pnmc

wget --progress=dot:mega https://github.com/yanntm/caesar.sdd/raw/gh-pages/caesar.sdd -O caesar.sdd
chmod a+x caesar.sdd

# Build bytecode only once. py_compile rather than "import pnmc": importing runs
# the driver, which reads BK_EXAMINATION and dies with a KeyError at install time.
python3 -m py_compile nupn.py pnmc.py

cd ..

#! /bin/bash
# libHSC has no CI publishing binaries yet: copy them from a local build.
#   HSC_BUILD=~/git/libHSC/build ./install.sh
set -e
HSC_BUILD=${HSC_BUILD:-$HOME/git/libHSC/build}
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
for t in hsc hsc-mcc nupn2hsc ; do
	cp "$HSC_BUILD/tools/$t" "$DIR/bin/$t"
	chmod +x "$DIR/bin/$t"
done
ls -la "$DIR/bin"

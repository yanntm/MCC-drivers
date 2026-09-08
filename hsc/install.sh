#! /bin/bash
# Install the libHSC binaries: by default the static builds published by the
# libHSC CI (branch HSC-Linux of yanntm/libHSC, see libHSC/doc/ci.md);
# with HSC_BUILD=<libHSC build tree> the binaries of a local build instead.
#   ./install.sh
#   HSC_BUILD=~/git/libHSC/build ./install.sh
set -e
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p "$DIR/bin"
for t in hsc hsc-mcc nupn2hsc ; do
	if [ -n "$HSC_BUILD" ] ; then
		cp "$HSC_BUILD/tools/$t" "$DIR/bin/$t"
	else
		wget -q --tries=5 "https://github.com/yanntm/libHSC/raw/HSC-Linux/$t" -O "$DIR/bin/$t"
	fi
	chmod +x "$DIR/bin/$t"
done
ls -la "$DIR/bin"

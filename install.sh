#! /bin/bash

# Deploys every tool that ships an install.sh in its own folder.
#
# NB: itstools/ is NOT cloned here, on purpose. The reducer (the "xred"
# variants) and the colored-model unfolding both need a checkout of
# ITS-Tools-MCC in itstools/, which you deploy yourself beforehand:
#     ./install_itstools.sh
# Once that folder exists its own install.sh is picked up by the loop below,
# like any other tool. See the Dockerfile of
# https://github.com/yanntm/MCC-server for a full setup.
#
# A tool that fails to install does not stop the others: we install what we can
# and report the failures at the end. Set MCC_INSTALL_STRICT=1 to also exit
# non-zero when something went wrong (useful in CI).

set -x

ok=()
ko=()

for i in */ ;
do
	tool=${i%/}
	if [ -f "$i/install.sh" ] ; then
		echo "Installing tool : $tool"
		if ( cd "$i" && ./install.sh ) ; then
			ok+=("$tool")
		else
			ko+=("$tool")
		fi
	fi
done

grep "timeout" ~/.profile > /dev/null 2>&1
if [ $? != 0 ]; then
	echo "alias timeout=$PWD/bin/timeout.pl" >> ~/.profile
	echo "shopt -s expand_aliases" >> ~/.profile
fi

set +x
echo ""
echo "==================== install summary ===================="
echo "installed : ${ok[*]:-(none)}"
if [ ${#ko[@]} -ne 0 ] ; then
	echo "FAILED    : ${ko[*]}"
	echo ""
	echo "These tools are unavailable; the others are usable."
	echo "Re-run this script, or the install.sh of a tool listed above,"
	echo "once the cause is fixed."
	echo "========================================================="
	if [ -n "$MCC_INSTALL_STRICT" ] ; then
		exit 1
	fi
else
	echo "all tools installed"
	echo "========================================================="
fi

if [ ! -x itstools/its-tools ] && [ ! -f itstools/BenchKit_head.sh ] ; then
	echo ""
	echo "NOTE: itstools/ is missing, so the reducer and the 'xred' variants"
	echo "      (e.g. BK_TOOL=tapaalxred) will not work. Run ./install_itstools.sh"
	echo "      to deploy it."
fi

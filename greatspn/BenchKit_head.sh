#!/bin/bash
#############################################################################
# This is an example for the MCC'2020
#############################################################################

#############################################################################
# In this script, you will affect values to your tool in order to let
# BenchKit launch it in an apropriate way.
#############################################################################

# BK_EXAMINATION: it is a string that identifies your "examination"

export PATH="$PATH:$BK_BIN_PATH/"

case "$BK_EXAMINATION" in

	StateSpace)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -gen # example of invocation
		;;

	UpperBounds)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -bound	 # example of invocation
		;;

	ReachabilityDeadlock)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -deadlock # example of invocation
		;;

	Reachability*)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -reach # example of invocation
		;;

	LTL*)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -ltl # example of invocation
		;;

	CTL*)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -ctl # example of invocation
		;;

	QuasiLiveness)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -qlive # example of invocation
		;;

	StableMarking)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -stablem # example of invocation
		;;

	Liveness)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -live # example of invocation
		;;

	OneSafe)
		$HOME/BenchKit/bin/greatspn_tool_2023.sh -onesafe # example of invocation
		;;

	*)
		echo "$0: Wrong invocation:" >> $BK_LOG_FILE
		exit 1
		;;
esac

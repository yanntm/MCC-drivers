#!/bin/bash
#############################################################################
# This is an example for the MCC'2015
#############################################################################

#############################################################################
# In this script, you will affect values to your tool in order to let
# BenchKit launch it in an apropriate way.
#############################################################################

# BK_EXAMINATION: it is a string that identifies your "examination"

export PATH="$PATH:/home/mcc/BenchKit/bin/"
$HOME/BenchKit/bin/pnmc.py

# case "$BK_EXAMINATION" in
#
#   StateSpace)
#     # $HOME/BenchKit/bin/dummy_tool.sh -gen
#     $HOME/BenchKit/bin/pnmc.py
#     ;;
#
#   LTL*)
#     # $HOME/BenchKit/bin/dummy_tool.sh -ltl
#     echo "DO NOT COMPETE"
#     ;;
#
#   CTL*)
#     # $HOME/BenchKit/bin/dummy_tool.sh -ctl
#     echo "DO NOT COMPETE"
#     ;;
#
#   Reachability*)
#     # $HOME/BenchKit/bin/dummy_tool.sh -reach
#     echo "DO NOT COMPETE"
#     ;;
#
#   *)
#     echo "$0: Wrong invocation:" >> $BK_LOG_FILE
#     exit 1
#     ;;
# esac

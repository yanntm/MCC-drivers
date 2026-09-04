#! /bin/bash

set -x
set -e

if [ ! -f oracle.tar.gz ] ; then 
	wget --progress=dot:mega https://yanntm.github.io/pnmcc-models-2026/oracle.tar.gz 
fi

if [ ! -d oracle/ ] ; then 
	tar xzf oracle.tar.gz 
fi

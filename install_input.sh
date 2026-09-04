#! /bin/bash

set -x

if [ ! -d INPUTS ] ; then
    mkdir INPUTS
fi

cd INPUTS

if [ ! -f $1.tgz ] ; then 
wget --progress=dot:mega https://github.com/yanntm/pnmcc-models-2026/blob/gh-pages/INPUTS/$1.tgz?raw=true -O $1.tgz
fi

if [ ! -d "$1$2" ] ; then
    mkdir "$1$2"
    cd "$1$2"
    tar xzf ../$1.tgz
    mv $1/* .
    \rm -r $1
    cd ..
fi

cd ..


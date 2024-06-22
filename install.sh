#! /bin/bash

#./install_itstools.sh

set -x

for i in */ ; 
do
	cd $i
	if [ -f  install.sh ] ; then 
	  echo "Installing tool : $i"
		./install.sh
	fi
	cd ..
done


grep "timeout" ~/.profile > /dev/null
if [ $? != 0 ]; then
	echo "alias timeout=$PWD/bin/timeout.pl" >> ~/.profile
	echo "shopt -s expand_aliases" >> ~/.profile
fi

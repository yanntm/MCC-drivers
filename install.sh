#! /bin/sh

./install_itstools.sh

for i in */ ; 
do
	cd $i
	if [ -f  install.sh ] ; then 
		./install.sh
	fi
	cd ..
done

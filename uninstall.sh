#! /bin/sh


rm -rf bin/itstools

for i in */ ; 
do
	cd $i
	if [ -f  uninstall.sh ] ; then 
		./uninstall.sh
	fi
	cd ..
done

#! /bin/sh

#./install_itstools.sh

for i in */ ; 
do
	cd $i
	if [ -f  install.sh ] ; then 
		./install.sh
	fi
	cd ..
done


grep "timeout" ~/.profile > /dev/null
if [ $? != 0 ]; then
	echo "alias timeout=$PWD/bin/timeout.pl" >> ~/.profile
	echo "shopt -s expand_aliases" >> ~/.profile
fi
source ~/.profile
 

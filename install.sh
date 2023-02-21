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


grep "timeout" ~/.bashrc > /dev/null
if [ $? != 0 ]; then
	echo "alias timeout=$PWD/bin/timeout.pl" >> ~/.bashrc
fi 

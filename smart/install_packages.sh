#! /bin/sh

# install as root
apt-get update

# java for the parsers
apt-get install openjdk-17-jdk 

for i in */install_packages.sh ; 
do
	$i
done

#! /bin/sh

# install as root
apt-get update

# packages for ITS-tools unfolder  
apt-get -y install ca-certificates python3 unzip openjdk-17-jdk psmisc

for i in ./*/install_packages.sh ; 
do
	$i
done

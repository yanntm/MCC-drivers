#! /bin/sh

# install as root
su
apt-get update
apt-get install git libboost-dev g++ ca-certificates python3 unzip openjdk-17-jdk psmisc

exit

cd 
cd BenchKit

git clone -depth 1 https://github.com/yanntm/MCC-drivers.git

cp -r MCC-drivers/pnmc/* .

# for unfolding
./install_itstools.sh

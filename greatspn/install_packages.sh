#! /bin/bash

# install as root
apt-get update

# java, some dev libs
apt-get -y install unzip openjdk-17-jdk 

# note that GreatSPN also needs :
# Spot (libspot.so) and related Buddy
# Meddly
# GMP with C++ bindings
# but these dependencies are currently embedded
 

#! /bin/sh

# Installation script for SMPT
mkdir -p bin

cd bin

if [ ! -x z3 ] ; then
	echo "Downloading z3"
	# using z3 4.12.1, available on GitHub   
	# export DLURL=https://github.com/Z3Prover/z3/releases/download/z3-4.12.1/z3-4.12.1-x64-glibc-2.35.zip
	
	# use this release for older systems that don't have recent glibc
	export DLURL=https://github.com/Z3Prover/z3/releases/download/z3-4.11.2/z3-4.11.2-x64-glibc-2.31.zip	
	wget --progress=dot:mega $DLURL -O z3.zip

	echo "Installing z3" 
    unzip z3.zip
    mv z3*/ z3dl/ 
    cp z3dl/bin/z3* .
    rm -rf z3dl/
    rm z3.zip
	echo "Done"
	echo ""
fi


if [ ! -x struct ] ; then
	echo "Installing Tina toolbox"
	wget --progress=dot:mega https://projects.laas.fr/tina/binaries/tina-3.7.5-amd64-linux.tgz
	tar xvf tina-3.7.5-amd64-linux.tgz
	rm tina-3.7.5-amd64-linux.tgz
	mv tina-3.7.5/bin/* .
	rm -rf tina-3.7.5/
	echo "Done"
	echo ""
fi


echo "Installing SMPT and 4ti2"
mkdir dl
cd dl
wget https://github.com/yanntm/SMPT-BinaryBuilds/archive/refs/heads/linux.tar.gz
tar xvzf linux.tar.gz
mv */* ..
cd ..
rm -rf dl/
tar xvzf smpt.tgz
rm smpt.tgz

echo "Install Octant"
wget https://github.com/nicolasAmat/Octant/raw/linux/octant.exe

chmod a+x *
chmod a+x ../BenchKit_head.sh
cd ..


echo "Please add the following lines in your .bashrc:"
echo "export PATH=${PWD}/bin:\$PATH"

echo "Done"


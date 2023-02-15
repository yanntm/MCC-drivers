#! /bin/sh

cd bin ;  
mkdir dl
cd dl
wget https://github.com/yanntm/LTSmin-BinaryBuilds/raw/gh-pages/ltsmin_linux_64.tar.gz
tar xvzf ltsmin_linux_64.tar.gz
mv lts_install_dir/bin/pnml* ..
cd ..
rm -rf dl/
cd ..

# for unfolding
./install_itstools.sh

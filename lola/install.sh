#! /bin/sh

cd bin ;  
mkdir dl
cd dl
wget https://github.com/yanntm/ExtractLola-2021/archive/refs/heads/gh-pages.tar.gz
tar xvzf gh-pages.tar.gz
mv ExtractLola-2021-gh-pages/* ..
cd ..
rm -rf dl/
cd ..

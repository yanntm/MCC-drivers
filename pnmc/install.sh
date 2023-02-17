#! /bin/sh


cd bin

wget https://github.com/yanntm/pnmc/raw/gh-pages/pnmc ; 
chmod a+x pnmc ; 

wget https://github.com/yanntm/caesar.sdd/raw/gh-pages/caesar.sdd ; 
chmod a+x caesar.sdd ; 

# build bytecode only once.
python -c "import nupn ; import pnmc"

cd ..

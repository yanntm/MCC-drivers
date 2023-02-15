#! /bin/bash

set -x

if [ ! -f bin/itstools/its-tools ] ; then 
	cd bin
	mkdir itstools
	cd itstools
	wget --progress=dot:mega https://lip6.github.io/ITSTools/fr.lip6.move.gal.itscl.product-linux.gtk.x86_64.zip
	unzip fr.lip6.move.gal.itscl.product-linux.gtk.x86_64.zip
	rm fr.lip6.move.gal.itscl.product-linux.gtk.x86_64.zip
	cd ../..
fi



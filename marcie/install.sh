#! /bin/bash

# grab archive
wget --no-check-certificate https://www-dssz.informatik.tu-cottbus.de/track/download.php?id=240 -O marcie.zip

# extract marcie
unzip -j marcie.zip marcie-linux64-20191118/bin/marcie -d .

mv marcie bin/

rm marcie.zip

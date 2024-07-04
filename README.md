# MCC-drivers

A driver to adapt various tools to Model Checking Contest formats.

## Contents

Each subfolder contains a tool and its MCC driver "BenchKit_head.sh" as well as references to the original tool this adapter is for (see the readme in each folder).

The parent folder contains a front-end that looks at variable `BK_TOOL` to decide which tool is wanted, 
and verifies that the target tool supports the given `BK_EXAMINATION`. If the target tool supports
 the examination only in PT mode, we add an unfolding step before invoking the tool. 
 These verifications use a file "SupportedExamination.txt" placed in each tool folder.

The front-end driver additionally supports a "reductions" mode, where its-tools is tasked to produce simpler model/formula pairs if possible.
This is triggered by appending `xred` to the tool name.

Currently supported tools (specify using `BK_TOOL` environment variable) :

 * itstools : ITS-Tools see https://github.com/yanntm/ITS-Tools-MCC 
 * ltsmin : LTSMin see https://github.com/utwente-fmt/ltsmin
 * smart : Smart see https://github.com/asminer/smart
 * pnmc : PNMC see https://github.com/ahamez/pnmc
 * lola : Lola see https://theo.informatik.uni-rostock.de/theo-forschung/tools/lola/
 * marcie : Marcie see https://www-dssz.informatik.tu-cottbus.de/DSSZ/Software/Marcie
 * smpt : SMPT see  https://github.com/nicolasAmat/SMPT
 * greatspn : GreatSPN see https://github.com/greatspn/SOURCES
 * tapaal : Tapaal see https://github.com/TAPAAL/ more precisely the verifypn component
    
 * ltsminxred : LTSMin + ITS-tools based reductions
 * smartxred : Smart + ITS-tools based reductions
 * lolaxred : Lola + ITS-tools based reductions
 * marciexred : Marcie + ITS-tools based reductions
 * smptxred : SMPT + ITS-tools based reductions
 * greatspnxred : GreatSPN + ITS-tools based reductions
 * tapaalxred : Tapaal + ITS-tools based reductions

## Installation

The installation requires a linux x64 machine, like the Ubuntu VM of the contest.

 0. If you are building a VM we need some basic packages to get started.
 
```
su
apt-get update
apt-get install git ca-certificates
exit
```

 1. Grab this repository into a cleared `/home/mcc/BenchKit` folder if you are on the VM. But any empty starting folder will do on another machine.
```
cd /home/mcc/BenchKit
rm -rf *
git clone https://github.com/yanntm/MCC-drivers.git .
cd itstools
git clone https://github.com/yanntm/ITS-Tools-MCC.git .
cd ..
```

 2. On a VM, as root, run the `install_packages.sh` script to have the appropriate packages installed.
 
 ```
 su
 ./install_packages.sh
 exit
 ```
 
 These commands use `apt-get` so might need to be adapted for e.g. a fedora linux distribution.
 The `install_packages.sh` scripts in each tool folder keep track of dependencies.
 
 3. Run the install script to deploy the tools
 
 ```
 ./install.sh
 ```
 
 4. We are now ready to run any of these tools in MCC mode.
 
 Build a folder containing :
 * a `model.pnml` file, 
 * an `examination.xml` file, 
 * if the model is colored, add a file named `iscolored` containing a single line "TRUE".

Possible examinations are :
 * Without an `examination.xml` file :
 ** StateSpace, OneSafe, StableMarking, QuasiLiveness, Liveness, ReachabilityDeadlock  
 * *With* an `examination.xml` file :
 ** UpperBounds, ReachabilityFireability, ReachabilityCardinality, CTLFireability, CTLCardinality, LTLFireability, LTLCardinality   
 
 In this folder, invoke the tool :
 ```
# Optional, give a name to the model
export BK_INPUT="MyModel"
# mandatory, see possible values above
export BK_EXAMINATION="StateSpace"
# mandatory, one of the tools/subfolders of this repository.
export BK_TOOL="ltsmin"
# this is in seconds, some tools honor the flag but not all
export BK_TIME_CONFINEMENT="3600"
# this is in MB, some tools honor the flag
export BK_MEMORY_CONFINEMENT="16384"
# mandatory set the path you deployed this repo in
export BK_BIN_PATH="/home/mcc/BenchKit/bin/" 
# invoke the driver.
$BK_BIN_PATH/../BenchKit_head.sh
 ```
 

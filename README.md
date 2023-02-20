# MCC-drivers

A driver to adapt various tools to Model Checking Contest formats.

## Contents

Each subfolder contains a tool and its MCC driver "BenchKit_head.sh".

The parent folder contains a front-end that looks at variable `BK_TOOL` to decide which tool is wanted, 
and verifies that the target tool supports the given `BK_EXAMINATION`. If the target tool supports
 the examination only in PT mode, we add an unfolding step before invoking the tool. 
 These verifications use a file "SupportedExamination.txt" placed in each tool folder.
  

## Installation

The installation requires a linux Ubuntu x64 machine, like the VM of the contest.

 0. If you are building a VM with "standard" paths, you should start in folder "/home/mcc/BenchKit" and clear it.

 1. Grab this repository :
```
export VERSION=0.0.1
wget https://github.com/yanntm/MCC-drivers/archive/refs/tags/v$VERSION.tar.gz
tar xvzf v$VERSION.tar.gz
mv MCC-drivers-$VERSION/* .
```

The "Releases" on the right might contain a more recent version so adapt the command as needed.  

 2. As root, run the `install_packages.sh` script to have the appropriate packages installed.
 
 ```
 su
 ./install_packages.sh
 exit
 ```
 
 These commands use `apt-get` so might need to be adapted for e.g. a fedora linux distribution.
 
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
 
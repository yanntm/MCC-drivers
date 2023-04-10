# ITS-Tools "reducer"

This folder contains invocation flags to use ITS-tools as a "reducer" before any other MCC compliant tool.

It relies on the presence of itstools/, that should be deployed using the install script at the root of this repository.

## Contents

Basically, this driver : 

* runs ITS-Tools, without the exhaustive engines (so we still have some random walks, SMT/Z3 approximations, a bunch of structural reduction rules)
* unless ITS-tools can answer all queries with these simple approaches, it will output a model.sr.pnml/examination.sr.pnml pair, that are typically simpler than the source models. This model is then passed on to an MCC compliant tool.

This driver was written by Yann Thierry-Mieg.
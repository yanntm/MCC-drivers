# LoLA

This folder contains the adapters for the tool LoLA  https://theo.informatik.uni-rostock.de/theo-forschung/tools/lola/
"A Low Level Petri Net Analyzer".

Karsten Wolf:
*Petri Net Model Checking with LoLA 2.* Petri Nets 2018: 351-362


## LoLA : A Low Level Petri Net Analyzer

Following description adapted from their website,

LoLA is a tool that can check whether a system (given as Petri net) satisfies a specified property. The property is evaluated by exhaustive and explicit exploration of a reduced state space. LoLA uses a broad range of state-of-the-art reduction techniques most of which can be applied jointly. Hence, LoLA typically needs to explore only a tiny fraction of the actual state space. The particularly strength of LoLA is the evaluation of simple properties such as deadlock freedom or reachability. Here, additional reduction techniques and specialized variants of techniques are applied.

### Understand LoLA

LoLA is a pure verification tool. It is not designed for supporting modeling. However, the interface is made such that integration of LoLA into a modeling framework is very easy. Input and output is organized as data streams (which may be files). LoLA reads a Petri net from an ASCII file and gets a property from another file or as command line parameter. The property (given as a formula in CTL*) is analysed and deferred to a suitable anaylzing routine (a CTL model checker, an LTL model checker, a reachability checker, or a deadlock checker). CTL* formulas that are not in one of the mentioned fragments, cannot be analysed. LoLA then outputs whether or not the property holds. In some cases, it can additionally produce a witness or counterexample path. Application of reduction techniques can be controlled by command line parameters.

State space reduction technqiues in LoLA include
* a symmetry method where, in contrast to most other tools, symmetries are detected automatically such that they preserve the net staructure as well as the formula;
* a partial order reduction that, in contrast to many other tools, uses specific variants for simple properties such as deadlock or reachability checking;
the sweep-line method where, in contrast to other tool, a suitable progress measure (which is a pre-requisite for this method) is automatically computed;
* Bloom filters (a reduction of states to hash values) where the number of involved hash functions can be controlled using a command line parameter;
* The coverability graph construction that can abstract infinite state spaces to a finite graph;
* Petri net specific preprocessing that accelerates some of the techniques.

Most techniques exploit the particular nature of Petri nets and therefore have the potential to outperform model checkers that work on general transition systems.

LoLA was written by Karsten Wolf and Niels Lohmann, with further contributors listed in the "AUTHORS" file of the distribution.

LoLA is a tool released under GNU AFFERO GENERAL PUBLIC LICENSE v3.

## LoLA in MCC
 
LoLA competed in the MCC from the very first edition in 2012 and almost continuously up to 2021. 

It typically ranked very high in every participation particularly for Reachability (where it dominated the first editions of the contest from 2012 up to 2017) and UpperBounds queries (until Marcie started winning in 2015-2017, but Lola was back to gold in 2018), entered and started winning the CTL category in 2016, entered LTL in 2016 and won the category in 2017. 

In 2018, while LoLA retained gold in upper bounds and LTL, it was pushed down to silver in reachability and CTL by new competitor Tapaal. In 2019, LoLA was silver in upper bounds, reachability and CTL categories (but still gold in LTL). Participation of LoLA in 2020 was skipped. In 2021, LoLA obtained silver in the (new) GlobalProperties category, bronze in Upper Bounds, Reachability and CTL, and fourth place in LTL. 

LoLA is an extremely solid competitor in all examinations of the MCC (except StateSpace where it never participated), and an efficient and reliable tool.
 
The first commit in this folder is a direct extraction from the VM submitted in MCC 2021 and available from the MCC site.
 
## Edits and changes
 
 This is a list of adaptations that were added to the original driver.
 
 * While Lola 2.0 is available from here https://theo.informatik.uni-rostock.de/theo-forschung/tools/lola/ unfortunately the whole website infrastructure (service-technology.org) as well as related source repository that was hosting LoLA is no longer available (at least publicly). We used the version we extracted from the 2021 submission to the MCC. See this companion Github repo https://github.com/yanntm/ExtractLola-2021
   
 * Hard coded references to /home/mcc/BenchKit/ are replaced by use of $BK_BIN_PATH
 
 * a script that automates the deployment on a naked VM is provided. 
  

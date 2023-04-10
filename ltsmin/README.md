# LTSmin

This folder contains the adapters for the tool LTSMin  http://ltsmin.utwente.nl/
a minimal tool set for manipulating labeled transition systems (LTS), that was progressively
 extended to a a full (LTL/CTL/μ-calculus) model-checker.

Their home page suggests we cite:
* Gijs Kant, Alfons Laarman, Jeroen Meijer, Jaco van de Pol, Stefan Blom and Tom van Dijk: *LTSmin: High-Performance Language-Independent Model Checking.* TACAS 2015
* Alfons Laarman, Jaco van de Pol and Michael Weber. *Multi-Core LTSmin: Marrying Modularity and Scalability.* NFM 2011
* Stefan Blom, Jaco van de Pol and Michael Weber. *LTSmin: Distributed and Symbolic Reachability.* CAV 2010

## What is LTSmin

Following description adapted from their website,

LTSmin started out as a generic toolset for manipulating labelled transition systems. Meanwhile the toolset was extended to a a full (LTL/CTL/μ-calculus) model checker, while maintaining its language-independent characteristics.

To obtain its input, LTSmin connects a sizeable number of existing (verification) tools: muCRL, mCRL2, DiVinE, SPIN (SpinS), UPPAAL (opaal), SCOOP, PNML, ProB and CADP. Moreover, it allows to reuse existing tools with new state space generation techniques by exporting LTSs into various formats.

Implementing support for a new language module is in the order of 200–600 lines of C “glue” code, and automatically yields tools for standard reachability checking (e.g., for state space generation and verification of safety properties), reachability with symbolic state storage (vector set), fully symbolic (BDD-based) reachability, distributed reachability (MPI-based), and multi-core reachability (including multi-core compression and incremental hashing).

The synergy effects in the LTSmin implementation are enabled by a clean interface: all LTSmin modules work with a unifying state representation of integer vectors of fixed size, and the PINS dependency matrix which exploits the combinatorial nature of model checking problems. This splits model checking tools into three mostly independent parts: language modules, PINS optimizations, and model checking algorithms.

On the other hand, the implementation of a verification algorithm based on the PINS matrix automatically has access to muCRL, mCRL2, DVE, PROMELA, SCOOP, UPPAAL xml, PNML, ProB, and ETF language modules.

Finally, all tools benefit from PINS2PINS optimizations, like local transition caching (which speeds up slow state space generators), matrix regrouping (which can drastically reduce run-time and memory consumption of symbolic algorithms), partial order reduction and linear temporal logic.

LTSMin was originally written by Michael Weber and Stefan Blom, but Alfons Laarman, Jeroen Meijer and Tom van Dijk are now the main contributors according to GitHub https://github.com/utwente-fmt/ltsmin/graphs/contributors

LTSMin is a tool released under the particularly permissive BSD3 license.


## LTSMin in MCC
 
LTSMin competed in the MCC from 2015 and almost continuously up to XXX. 

While it performs decently in almost all categories, with a high reliability, it was not on the podium in 2015 (obtaining fourth to sixth place).
In 2016 LTSMin won gold in LTL, then silver in 2017 and 2018 (overtaken by LoLA).
In 2019 a symbolic version of LTSMin was submitted, that no longer participated in LTL. 
This was the last participation of LTSMin to the MCC.
 
The first commit in this folder is a direct extraction from the VM submitted in MCC 2019 and available from the MCC site.
 
## Edits and changes
 
 This is a list of adaptations that were added to the original driver.
 
 * We did a mix of the drivers from 2018 and 2019 in this driver. The 2018 edition uses mostly "pnml2lts-mc", the multi-core and partial order aware explicit engine of LTSMin, while 2019 is focused on the pnml2lts-sym engine, driven by Lace and Sylvan libraries for efficient decision diagram based strategies.
 
 * We patched the driver flags injecting `-precise` to compute exact state counts (though this was after MCC2023 participation)
 
 * We patched some other flags to be consistent with modern releases of LTSMin. 
   
 * Hard coded references to /home/mcc/BenchKit/ are replaced by use of $BK_BIN_PATH
 
 * a script that automates the deployment on a naked VM is provided. 
  
 * See the history of this folder for more details on the patches introduced, they are more numerous than in most drivers.

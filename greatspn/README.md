# GreatSPN

This folder contains the adapters for the tool GreatSPN  

https://github.com/greatspn/SOURCES


See the reference [(pdf)](https://iris.unito.it/retrieve/handle/2318/1624717/295450/Amparore-trivedi-chapter.pdf):

Elvio Amparore, Gianfranco Balbo,  Marco Beccuti, Susanna Donatelli, and Giuliana Franceschinis:
"30 years of *GreatSPN*", in Principles of Performance and Reliability Modeling and Evaluation, 2016 : 227-254.


## GreatSPN (GRaphical Editor and Analyzer for Timed and Stochastic Petri Nets) 

Following description adapted from their website,

GreatSPN is a software package for the modeling, validation, and performance evaluation of distributed systems using Generalized Stochastic Petri Nets and their colored extension, Stochastic Well-formed Nets. The tool provides a friendly framework to experiment with (stochastic) Petri net based modeling techniques. It implements efficient analysis algorithms to allow its use on rather complex applications.

GreatSPN is a tool released under GNU GENERAL PUBLIC LICENSE v2.

## GreatSPN in MCC
 
GreatSPN competed in the MCC from the 2013 edition and continuously up to 2023.

The current engine used in MCC scenarios is based on [Meddly](https://github.com/asminer/meddly) a powerful decision diagram library and uses very general decision procedures able to deal with CTL* formulas.

J. Babar, M. Beccuti, S. Donatelli, and A. S. Miner. Greatspn enhanced with decision diagram data structures. In Proc. of 31st International Conference, volume 6128 of Lecture Notes in Computer Science. Springer, pages 308-317, 2010.

Elvio Gilberto Amparore, Susanna Donatelli, Francesco Gallà: 
starMC: an automata based CTL* model checker. PeerJ Comput. Sci. 8: e823 (2022)

GreatSPN embeds its own analysis methods for Colored nets thus can deal with all models, and can handle every examination of the MCC, making it a versatile tool.

In terms of rankings, it is [regularly on the podium for StateSpace](https://yanntm.github.io/MCC-analysis/state_space_annual.html) and can in all categories answer queries other tools cannot particularly hard queries that need to have built the whole state space [The small red and green bars in these diagrams](https://yanntm.github.io/MCC-analysis/invcex/toolinvcexhard.html), but suffers in the MCC scoring from the (bias in favour of counter examples currently in the MCC)[https://yanntm.github.io/MCC-analysis/invcex/invcex.html].

GreatSPN is a versatile and very reliable tool practically always scoring 100% reliability over many editions of the MCC.
 
The first commit in this folder is a direct extraction from the VM submitted in MCC 2023 and available from the MCC site.
 
## Edits and changes
 
 This is a list of adaptations that were added to the original driver.
     
 * Hard coded references to /home/mcc/BenchKit/ and links to /opt/greatspn are replaced by use of $BK_BIN_PATH and subfolders of this one.
 
  

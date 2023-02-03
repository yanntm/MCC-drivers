# PNMC

This folder contains the adapters for the tool PNMC  https://github.com/ahamez/pnmc
"An efficient Petri net model checker using Hierarchical Set Decision Diagrams".

This also embeds Caesar.SDD https://github.com/ahamez/caesar.sdd that simulates some
 of the behaviors of the Caesar.BDD tool from the CADP framework, but using SDD as data structure.
 
 Both of these tools leverage libsdd https://github.com/ahamez/libsdd "a generic C++14 library for Hierarchical Set Decision Diagrams".
 
 All these tools are developed by Alexandre Hamez.
 
 PNMC competed for MCC in 2015 and 2016, participating in the StateSpace examination only.
 
 The first commit in this folder is a direct extraction from the VM submitted in MCC 2016 and available from the MCC site.
 
 ## Edits and changes
 
 This is a list of adaptations that were added to the original driver.
 
 * We no longer have known vs surprise models per se. We are supposed to only use the information in the model folder,
  so that storing precomputed orders for some models is not legit anymore. Clearing the "orders" folder accomplishes this.
  
 * Hard coded references to /home/mcc/BenchKit/ are replaced by use of $BK_BIN_PATH
 
 * a script that automates the deployment and compilation on a naked VM is provided. 
 
 

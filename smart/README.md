# SMART

This folder contains the adapters for the tool Smart  https://asminer.github.io/smart/
"Stochastic Model-checking Analyzer for Reliability and Timing".
 
This tool leverages meddly https://asminer.github.io/meddly/ "Multi-terminal and Edge-valued Decision Diagram LibrarY. It is an open-source software library that supports several types of decision diagrams, including binary decision diagrams (BDDs)."
 
These tools are developed by Andrew S. Miner, Gianfranco Ciardo and others. 

See the github pages for more contributors, https://github.com/asminer/smart and https://github.com/asminer/meddly
 
Smart competed in the MCC 2016, 2017, 2018, 2019 and 2020.
 
 The first commit in this folder is a direct extraction from the VM submitted in MCC 2020 and available from the MCC site.
 
 ## Edits and changes
 
 This is a list of adaptations that were added to the original driver.
   
 * Hard coded references to /home/mcc/BenchKit/ are replaced by use of $BK_BIN_PATH
 
 * a script that automates the deployment and compilation on a naked VM is provided. 
 
 

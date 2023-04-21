# SMPT

This folder contains the adapters for the tool SMTP  https://github.com/nicolasAmat/SMPT
"SM(P/)T - Satisfiability Modulo Petri Net".
 
This tool leverages components of Tina https://projects.laas.fr/tina/index.php
 
These tools are developed by
*    Nicolas AMAT - LAAS/CNRS
*    Bernard BERTHOMIEU - LAAS/CNRS
*    Silvano DAL ZILIO - LAAS/CNRS
*    Didier LE BOTLAN - LAAS/CNRS
 
SMPT competed in the MCC 2021 and 2022 (reaching bronze in Reachability in 2022).

This driver is based on files provided with SMPT on its home page.
 
 ## Edits and changes
 
 This is a list of adaptations that were added to the original driver.
   
 * Hard coded references to /home/mcc/BenchKit/ are replaced by use of $BK_BIN_PATH
 
 * all executable components are now simply installed, which limits the number of packages we need to compile everything to get the tool to run 
 
 * a script that automates the deployment on a naked VM is provided. 
 
 
 
 

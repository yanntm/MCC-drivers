# MARCIE

This folder contains the adapters for the tool MARCIE  https://www-dssz.informatik.tu-cottbus.de/DSSZ/Software/Marcie
"Model checking And Reachability analysis done effiCIEntly".

M Heiner, C Rohr and M Schwarick:
*MARCIE - Model checking And Reachability analysis done effiCIEntly;*
In Proc. PETRI NETS 2013, Milano, Springer, LNCS, volume 7927, pp. 389–399, June 2013 [e-link](http://link.springer.com/chapter/10.1007/978-3-642-38697-8_21). 

Following description adapted from their website,

## Marcie - (M)odel checking (A)nd (R)eachability analysis done effi(CIE)ntly

Marcie is a tool for qualitative and quantitative analysis of Generalized Stochastic Petri nets with extended arcs.

In the context of MCC, we only use the Qualitative analysis based on Interval Decision Diagrams (IDD), that features :
 *  no previous knowledge of the boundedness degree required;
 *  efficient saturation-based reachability analysis;
 *   pre-computation of suitable static variable orders ;
 *   dead state analysis with trace generation;
 *   analysis of strongly connected components (liveness, reversibility);
 *   efficient CTL model checking;  

Authors of Marcie (as credited when running the tool) are :
 *  Alex Tovchigrechko (IDD package and CTL model checking)
 *  Martin Schwarick (Symbolic numerical analysis and CSL model checking)
 * Christian Rohr (Simulative and approximative numerical model checking)

## Marcie in MCC
 
MARCIE competed in the MCC from the very first edition in 2012 and continuously up to 2017. 
It typically ranked very high in every participation particularly for CTL and UpperBounds queries.

As discussed [on their page](https://www-dssz.informatik.tu-cottbus.de/DSSZ/Software/Marcie#news) Marcie would even be ranked much higher
without the complex scoring system of MCC (with multipliers for "surprise" models, "normalized" points for models with many instances...)
 and simply counting the number of correct answers. 
 
The first commit in this folder is a direct extraction from the VM submitted in MCC 2017 and available from the MCC site.
 
## Edits and changes
 
 This is a list of adaptations that were added to the original driver.
   
 * added flag `--mcc-mode` since this is no longer the default in recent Marcie.
 
 * Hard coded references to /home/mcc/BenchKit/ are replaced by use of $BK_BIN_PATH
 
 * a script that automates the deployment on a naked VM is provided. 
 
 * a "license" file was added, with the text from the home page.
 

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
The published rankings from 2014 on give Marcie as gold in StateSpace in 2014 (single examination it participated in),
 then in 2015 gold StateSpace, bronze in reachability and gold in CTL, in 2016 silver state space (overtaken by ITS-Tools), gold upper bounds (first edition of the category in the MCC), and bronze CTL (overtaken by Tapaal and LoLA). 
 2017 was the last year Marcie participated, gaining a bronze medal in UpperBounds and performing quite well in CTL.

As discussed [on their page](https://www-dssz.informatik.tu-cottbus.de/DSSZ/Software/Marcie#news) Marcie would even be ranked much higher
without the complex scoring system of MCC (with multipliers for "surprise" models, "normalized" points for models with many instances...)
 and simply counting the number of correct answers. It's a fact that despite *answering more queries than other competitors* they were not
  even on the CTL podium. 
  
  While it's true the 2017 "surprise models" were particularly nasty for symbolic techniques, it kind of balances itself out over time as the number and diversity of models in the MCC benchmark has grown. Marcie is a also *particularly stable* and *very reliable* tool, that uses very effective decision diagram technology (DD might not always be effective, but on favorable models they can really be amazing), so we are pleased to provide this adapter.
 
The first commit in this folder is a direct extraction from the VM submitted in MCC 2017 and available from the MCC site.
 
## Edits and changes
 
 This is a list of adaptations that were added to the original driver.
   
 * added flag `--mcc-mode` since this is no longer the default in recent Marcie.
 
 * Hard coded references to /home/mcc/BenchKit/ are replaced by use of $BK_BIN_PATH
 
 * a script that automates the deployment on a naked VM is provided. 
 
 * a "license" file was added, with the text from the home page.
 

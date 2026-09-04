# PetriSpot driver

Runs the explicit heuristic walk engine of [PetriSpot](https://github.com/yanntm/PetriSpot)
on P/T nets for `ReachabilityCardinality`, `ReachabilityFireability` and
`ReachabilityDeadlock`. It only produces verdicts backed by a witness (a
reachable state), so a property with no counter-example stays unanswered;
combine with the reducer (`BK_TOOL=petrispotxred`) to let ITS-Tools settle the
impossible queries and reduce the net first.

* `BenchKit_head.sh` — the driver: a portfolio of walkers (default 4 threads,
  strategies `random,bestfirst,structural,relaxed`) scheduled in rounds of
  increasing per-property budget within `BK_TIME_CONFINEMENT`.
  Environment knobs: `PETRISPOT_THREADS`, `PETRISPOT_STRATEGIES`,
  `PETRISPOT_FLAGS`, `PETRISPOT_MARGIN`.
* `install.sh` — downloads `petri64` from the PetriSpot CI (`Inv-Linux`
  branch), or copies `$PETRISPOT_BIN` when set.
* `SupportedExamination.txt` — the three PT reachability examinations.

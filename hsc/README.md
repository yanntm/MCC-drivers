# `hsc/` — libHSC in the MCC harness

`BenchKit_head.sh` answers StateSpace, OneSafe, ReachabilityDeadlock,
ReachabilityCardinality, ReachabilityFireability, UpperBounds,
CTLCardinality and CTLFireability on P/T nets
with `hsc-pn` (libHSC, <https://github.com/yanntm/libHSC>, `tools/README.md`
there): four configurations run in parallel on the examination (the NUPN
unit tree as the shape; FORCE reordering; Louvain decomposition; Louvain then
FORCE), their `FORMULA` / `STATE_SPACE` lines are merged by property name,
the first configuration to answer everything stops the others. No
configuration dominates on the contest models, hence the portfolio; `hsc-pn`
is single threaded so the four fit the contest's cores, and each gets a
quarter of the memory confinement (`ulimit -v`), so the portfolio as a whole
stays under the limit. `HSC_CONFS="louvain-force"` (space separated names
among `nupn force louvain louvain-force`) runs a subset, a single one with
the whole memory: the rerun of the best configuration after a portfolio
sweep. `HSC_APPROX=1` makes the reachability examinations run the over-approximation
first (`hsc-pn --approx`: the invariant set, the properties it refutes, a
backward search inside it) and the fixpoint after, under `--totalTime`; the
`hscapprox/` folder is that setting as a tool of its own. An examination with no
answer is `CANNOT_COMPUTE`. Partial results retain their answer lines and use
an ordinary `answered N of M` diagnostic, never an examination-wide failure token.

`install.sh` downloads the static binaries published by the libHSC CI (branch
`HSC-Linux` of `yanntm/libHSC`), or copies them from a local build with
`HSC_BUILD=<build tree>`. Known limits and the measurements behind the
design: `libHSC_in_MCC.md` in the PetriSpot repository.

On a coloured instance the harness unfolds the net with ITS-Tools (we declare
P/T only) and that unfolder fuses symmetric bindings without reporting their
multiplicity: the net we receive has the right states but fewer arcs than the
coloured semantics. StateSpace therefore answers three values there and leaves
TRANSITIONS unanswered rather than reporting an undercount (measured on
BART-COL-002/005/010: a constant 167/202 of the oracle).

`HSC_REDUCE=1` passes `--reduce` to every configuration. Optional
`HSC_REDUCE_TIME=<seconds>` and `HSC_DEAD_TEST=linear|lp|both|none`
override the reduction budget and dead-transition test. With no overrides,
`hsc-pn` defaults apply (10 seconds, `linear`). The log records the flags.
Reduction remains disabled unless explicitly requested.

StateSpace passes the internal deadline to hsc-pn as well as bounding the
process externally. A two-second termination grace keeps a stuck child from
outliving the harness confinement.

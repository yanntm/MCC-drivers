# `hsc/` — libHSC in the MCC harness

`BenchKit_head.sh` answers StateSpace, OneSafe, ReachabilityDeadlock,
ReachabilityCardinality, ReachabilityFireability and UpperBounds on P/T nets
with `hsc-pn` (libHSC, <https://github.com/yanntm/libHSC>, `tools/README.md`
there): four configurations run in parallel on the examination (the NUPN
unit tree as the shape; FORCE reordering; Louvain decomposition; Louvain then
FORCE), their `FORMULA` / `STATE_SPACE` lines are merged by property name,
the first configuration to answer everything stops the others. No
configuration dominates on the contest models, hence the portfolio; `hsc-pn`
is single threaded so the four fit the contest's cores, and each gets a
quarter of the memory confinement (`ulimit -v`), so the portfolio as a whole
stays under the limit. What no
configuration answered within the confinement is `CANNOT_COMPUTE`.

`install.sh` downloads the static binaries published by the libHSC CI (branch
`HSC-Linux` of `yanntm/libHSC`), or copies them from a local build with
`HSC_BUILD=<build tree>`. Known limits and the measurements behind the
design: `libHSC_in_MCC.md` in the PetriSpot repository.

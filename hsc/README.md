# `hsc/` — libHSC in the MCC harness (prototype)

`BenchKit_head.sh` answers StateSpace (the STATES value) and OneSafe on P/T nets
with libHSC (<https://github.com/yanntm/libHSC>): `nupn2hsc` imports the PNML
into the `.hsc` surface once, then four configurations of `hsc` run in parallel
on it (the NUPN unit tree as the shape; FORCE reordering; Louvain
decomposition; Louvain then FORCE) and the first answer wins. No configuration
dominates on the contest models, hence the portfolio; `hsc` is single threaded
so the four fit the contest's cores.

`install.sh` downloads the static binaries published by the libHSC CI (branch
`HSC-Linux` of `yanntm/libHSC`), or copies them from a local build with
`HSC_BUILD=<build tree>`. Known limits and the measurements behind the
design: `libHSC_in_MCC.md` in the PetriSpot repository.

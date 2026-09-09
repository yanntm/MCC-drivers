# `hscapprox/` — libHSC, the over-approximation first

The `hsc` driver with `HSC_APPROX=1`: on ReachabilityCardinality and
ReachabilityFireability, `hsc-pn --approx 5 --approx-units --approx-back 50`
builds the invariant set of the net, answers the properties it refutes and
the ones a backward search inside it decides, then runs the fixpoint under
`--totalTime` for the rest. The binaries are `../hsc/bin` (install there).
A tool of its own so the two settings run one examination side by side.

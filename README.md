# MCC-drivers : MCC-compliant drivers for Petri net verification tools

This project wraps a set of current and past competitors of the
[Model Checking Contest](https://mcc.lip6.fr) (MCC) behind a single MCC-compliant
`BenchKit_head.sh`. Two things come out of it :

* a uniform way to run any of these tools on MCC inputs (a `model.pnml` plus an
  `<Examination>.xml`), without learning each tool's own command line ;
* the **`+red` family** of combination tools, in which
  [ITS-Tools](https://github.com/yanntm/ITS-Tools-MCC) is used as a simplifying front-end
  (structural reductions, SMT-based simplification, query rewriting) and hands the residual
  model and the remaining queries to one of these engines. Submitted to the contest as
  `LoLA+red`, `GreatSPN+red`, `LTSMin+red`, `Marcie+red` or `Smart+red`, these have collected
  a good share of our MCC medals.

While it should run anywhere we have bash and perl, it is only really tested on Linux, since
these are the contest conditions.

## Wrapped tools

Each tool lives in its own folder with a `BenchKit_head.sh`, a `SupportedExamination.txt`, an
`install.sh` and an `uninstall.sh`. See the `README.md` in each folder for credits, references
and a description of the tool.

| Folder | Tool | Examinations | Nets |
|--------|------|--------------|------|
| `greatspn/` | [GreatSPN](https://github.com/greatspn/SOURCES) | all of them | P/T and colored |
| `tapaal/` | [Tapaal](https://www.tapaal.net/) | all but StateSpace | P/T and colored |
| `lola/` | [LoLA](https://theo.informatik.uni-rostock.de/theo-forschung/tools/lola/) | all but StateSpace; CTL and LTL on P/T only | P/T and colored |
| `marcie/` | [Marcie](https://www-dssz.informatik.tu-cottbus.de/DSSZ/Software/Marcie) | StateSpace, UpperBounds, Reachability, CTL | P/T and colored |
| `smpt/` | [SMPT](https://github.com/nicolasAmat/SMPT) | Reachability | P/T and colored |
| `ltsmin/` | [LTSmin](https://ltsmin.utwente.nl/) | StateSpace, UpperBounds, Reachability, CTL, LTL | P/T |
| `smart/` | [Smart](https://asminer.github.io/smart/) | StateSpace, UpperBounds, GlobalProperties, Reachability | P/T |
| `petrispot/` | [PetriSpot](https://github.com/yanntm/PetriSpot) | Reachability, witness-backed verdicts only | P/T |
| `pnmc/` | [pnmc](https://github.com/ahamez/pnmc) | StateSpace | P/T |
| `reducer/` | the ITS-Tools reducer, used by the `xred` variants | — | — |

`SupportedExamination.txt` is authoritative for what a given tool answers, and for whether it
does so on P/T nets, colored nets, or both. When a tool supports an examination on P/T only,
the driver unfolds the colored model first, using ITS-Tools.

## Install

```sh
git clone https://github.com/yanntm/MCC-drivers.git
cd MCC-drivers
sudo ./install_packages.sh   # system packages, for all tools
./install_itstools.sh        # see below, needed for the reducer and for colored models
./install.sh                 # deploys every tool
```

`install.sh` deploys each tool that ships an `install.sh`, and prints a summary of what was
installed and what failed. A tool that fails to install does not stop the others: you keep a
usable installation of everything else. Set `MCC_INSTALL_STRICT=1` if you want a non-zero exit
status when something went wrong.

**`install_itstools.sh` is deliberately not called by `install.sh`.** It clones
[ITS-Tools-MCC](https://github.com/yanntm/ITS-Tools-MCC) into `itstools/`, which is required by
the reducer (all the `xred` variants) and by the unfolding of colored models. Run it yourself
before `install.sh`, or point `itstools/` at your own checkout. For a full, reproducible setup,
see the `Dockerfile` of [MCC-server](https://github.com/yanntm/MCC-server), which builds this
whole stack as a container image.

`./uninstall.sh` removes the deployed binaries again.

## Usage

The tool is selected with `BK_TOOL`, and the rest is plain MCC:

```sh
export BK_TOOL=tapaal
export BK_EXAMINATION=ReachabilityCardinality
export BK_BIN_PATH=$PWD/bin/
export BK_TIME_CONFINEMENT=3600
export BK_INPUT=$PWD
./BenchKit_head.sh
```

Suffix the tool name with **`xred`** to get the `+red` variant, which runs the ITS-Tools reducer
first and only calls the back-end engine on what is left :

```sh
export BK_TOOL=tapaalxred
```

An unknown `BK_TOOL`, or an examination the tool does not support, answers `DO_NOT_COMPETE` as
the contest rules require.

## Testing

The regression harness lives in [pnmcc-tests](https://github.com/yanntm/pnmcc-tests) and is
unpacked next to `BenchKit_head.sh` :

```sh
git clone https://github.com/yanntm/pnmcc-tests.git
cp -r pnmcc-tests/* .
./install_oracle.sh
```

Oracles come from [pnmcc-models-2026](https://github.com/yanntm/pnmcc-models-2026). Run one test
with `BK_TOOL` set to the driver under test :

```sh
BK_TOOL=tapaal ./run_test.pl oracle/Angiogenesis-PT-05-RC.out -t 300
```

`run_test.pl` returns zero only if the test passed. Any flag after the oracle name is handed to
`BenchKit_head.sh` as is. A series of tests, keeping a non-zero status if any of them failed :

```sh
export TEST=oracle/*-RF.out
(rc=0 ; for MODEL in $TEST ; do BK_TOOL=tapaal ./run_test.pl $MODEL -t 300 || rc=$? ; done; exit $rc)
```

Two things to keep in mind when testing :

* **Give it a real time budget.** Several drivers slice `BK_TIME_CONFINEMENT` into sub-budgets
  and degrade badly when it is small: Tapaal, for instance, answers nothing at `-t 60` and
  everything in about a second at `-t 300`. Use at least 300 seconds even on tiny models.
* **Not every tool answers everything.** PetriSpot only emits verdicts backed by a witness, so a
  property with no counter-example stays unanswered by design; Smart and pnmc simply run out of
  time on some queries. The harness then reports "less results than expected" even though no
  answer is wrong, so check whether the log has actual `failed test expected/real` lines before
  calling it a regression. Running these as `xred` variants gives complete runs.

The `analysis/` folder of pnmcc-tests has scripts to turn raw logs into CSV data points.

## Known issues

* The `ltsmin` driver asks for `--vset=lddmc`, which the currently published
  [LTSmin-BinaryBuilds](https://github.com/yanntm/LTSmin-BinaryBuilds) binary does not provide
  (it offers `ldd`, `ldd64` and `fdd`), so `pnml2lts-sym` fails with *unknown vector set
  implementation lddmc* and answers nothing. Pending a rebuild of the binary with Sylvan.

## License

This project is made available in the hope it may prove useful.
This project source code is released under the terms of
[GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).

(c) Yann Thierry-Mieg. LIP6, Sorbonne Université, CNRS.

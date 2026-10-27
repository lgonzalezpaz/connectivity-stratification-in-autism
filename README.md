# The stability ceiling of connectome subtypes

Code and derived results for the manuscript *"A measurement ceiling explains the
developmental instability of autism connectivity subtypes"*.

The repository reproduces, from public data and with no credentialed access,
every number, table and figure in the manuscript: the closed-form stability
ceiling and its Monte-Carlo validation, the subtype discovery and reliability
analyses in ABIDE II, the first direct measurement of intraindividual subtype
stability across 1.6–2.0 years, the connectome-identifiability analysis, the
independent ABIDE I replication, and the design calculator.

Total runtime on a single 4-core machine is about 3 h, of which roughly 45 min
is downloading ~7 GB of public derivatives. No GPU is required.

---

## 1. What the analysis does

| Step | Script | Output |
|---|---|---|
| Index and download ABIDE II DCAN derivatives and all phenotypic tables | `code/01_index_and_download.py` | `data/raw/`, `data/pheno/` |
| Reconstruct per-frame framewise displacement, cache parcellated time series | `code/02_extract_qc_and_timeseries.py` | `results/qc_sessions.csv` |
| Closed-form stability ceiling + Monte-Carlo self-test | `code/03_theory.py` | prints Table S1 |
| Duration-matched connectomes and within-session split halves | `code/04_build_connectomes.py` | `data/conn_*.npy` |
| Attach open phenotypic data | `code/05_phenotype.py` | `results/phenotype_sessions.csv` |
| Subtype discovery, reliability, within-session ceiling test | `code/06_subtyping_and_reliability.py` | `results/06_subtyping.json` |
| Intraindividual stability across waves + sensitivity analyses | `code/07_longitudinal.py` | `results/07_longitudinal.json` |
| Design calculator and power curves | `code/08_design_calculator.py` | `results/08_design.json` |
| Machine-verified bibliography (Crossref + PubMed) | `code/09_verify_references.py` | `results/references_verified.json` |
| Connectome identifiability across development | `code/10_identifiability.py` | `results/10_identifiability.json` |
| Independent ABIDE I replication (C-PAC, CC200) | `code/11a_download_abide1.py`, `code/11b_abide1_replication.py` | `results/11_abide1_replication.json` |
| Figures | `code/12_figures.py` | `figures/figure[1-5]*.pdf/.png` |
| Reliability-sensitivity addenda and manuscript tables | `code/13_addenda.py` | `results/13_addenda.json` |
| Survey of the public NDA collection catalogue (metadata only, no credentials) | `code/14_nda_catalogue.py` | `results/nda_candidates.json`, `results/nda_shortlist.md` |
| Repeat-scan connectomes from CoRR | `code/15_corr_download.py` | `data/corr/` |
| Attempt to measure the between-session state term (reported as a negative result) | `code/16_decorrelation.py` | `results/16_decorrelation.json` |
| Preregistered protocol for controlled-access infant cohorts | `code/17_nda_adapter.py`, `preregistration/` | audit and analysis entry points |

`code/pipeline.py` holds the shared subtyping pipeline so that every sensitivity
analysis repeats an identical sequence of steps with one option changed.

## 2. Reproducing it

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt          # or: conda env create -f environment.yml
make all                                 # or run the scripts in numerical order
```

`make all` is ordered; individual steps can be re-run and will reuse anything
already downloaded. `make theory` runs only the closed-form/Monte-Carlo check,
which needs no data and takes under a minute — the quickest way to confirm the
central equations.

## 3. Data

All inputs are public and require no data-use agreement.

| Source | What is used | Where it comes from |
|---|---|---|
| ABIDE II, DCAN derivatives | parcellated resting-state time series (Gordon 352, Glasser 379, Power 94, M132 205 parcels) and framewise-displacement masks for 1,009 sessions | `s3://fcp-indi/data/Projects/ABIDE2/Derivatives/DCAN/` (anonymous HTTP) |
| ABIDE II phenotypic tables | diagnosis, age, sex, IQ, ADOS/ADI/SRS, site | `fcon_1000.projects.nitrc.org/indi/abide2/release/phenotypic_data/` |
| ABIDE I, Preprocessed Connectomes Project | CC200 ROI time series, two denoising strategies, 1,035 subjects | `s3://fcp-indi/data/Projects/ABIDE_Initiative/Outputs/cpac/` |

The two ABIDE II longitudinal collections (UPSM_Long, UCLA_Long) are the only
openly available resting-state data in which the same autistic individuals were
scanned twice during development; their baseline scans were released in ABIDE I
and their follow-up scans in ABIDE II. The scripts resolve that correspondence
from the released phenotypic tables, not by assumption.

Nothing in this repository redistributes the primary imaging data; the download
scripts fetch it from the original archives.

## 4. The central result in six lines

```python
import importlib.util
spec = importlib.util.spec_from_file_location("th", "code/03_theory.py")
th = importlib.util.module_from_spec(spec); spec.loader.exec_module(th)

th.kappa_max_continuum(0.74)   # ceiling if subtypes cut a continuum
th.kappa_max_categorical(0.74) # ceiling if subtypes are a true dichotomy
th.duration_for_kappa(0.6, rho_ref=0.74, T_ref=150)   # seconds of data needed
```

## 5. Verifying the bibliography

`code/09_verify_references.py` resolves every cited DOI against Crossref and
PubMed, prints a Vancouver-formatted list, and records the retrieved metadata
and abstracts in `results/references_verified.json`. Re-running it is the
intended way to audit the manuscript's citations; it flags any DOI that does not
resolve to the work the claim attributes to it.

## 6. What did not work, and is reported as such

`code/16_decorrelation.py` attempts to measure the between-session state term
from the CoRR repeat-scan resource. It fails for two documented reasons: the
released connectomes are magnitude-valued and not commensurable with signed
connectivity, and between-site heterogeneity swamps the interval effect. The
script, its output and the pre-specified bridge test that gated it are kept in
the repository because the attempt is the obvious one for a reader to propose,
and because the negative result is reported in the manuscript.

## 7. Preregistered extension

`preregistration/PREREGISTRATION.md` specifies, in advance of any data access,
how this framework should be tested in prospective infant-sibling cohorts held
in controlled-access repositories, and `code/17_nda_adapter.py --audit` answers
the prerequisite question: how many participants there have two or more usable
resting-state scans. The authors hold no data-use certification for those
collections; the protocol is deposited so that groups that do can execute it
unchanged.

## 8. Licence and citation

Code is released under the MIT Licence (`LICENSE`). Please cite the manuscript
and, separately, the ABIDE I and ABIDE II data descriptors and the DCAN and
Preprocessed Connectomes Project derivative releases, whose terms govern the
primary data. See `CITATION.cff`.

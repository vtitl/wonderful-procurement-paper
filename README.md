# Replication Package for "[PAPER TITLE]"

> **Authors:** [Author 1], [Author 2], [Author 3]
> **Journal:** American Economic Journal: Applied Economics
> **Manuscript Number:** [AEJApp-XXXX-XXXX]

---

## Overview

This replication package reproduces all tables and in-text statistics reported in "[PAPER TITLE]." Every number in the paper is generated programmatically from the source data: running `code/main.sh` produces all outputs, and recompiling the LaTeX source then yields an up-to-date paper with no manual editing required.

---

## Data Availability and Provenance Statements

### Statement of Rights

The authors of the paper had legitimate access to and permission to use the data used in this paper. The raw data **cannot** be publicly redistributed; see below for access instructions.

### Data Sources

| Dataset | Source | Access | Provided |
|---|---|---|---|
| `super_tender_analytics_criteria_202602121648.csv` | [DATA SOURCE — e.g., national procurement registry / government open-data portal] | [ACCESS INSTRUCTIONS — e.g., freely downloadable at URL, or restricted — see below] | No |

**Access to restricted data:** [Describe how a replicator can request or obtain access to the raw data. Include contact information, any data-use agreements that must be signed, and approximate wait time if applicable.]

---

## Dataset List

| File | Location | Format | Description | Provided |
|---|---|---|---|---|
| `super_tender_analytics_criteria_202602121648.csv` | `$WONDERFUL_DROPBOX_PATH/raw/` | CSV | Raw tender procurement records | No |
| `main.dta` | `data/processed/` | Stata `.dta` | Cleaned and merged analysis dataset (2.57 GB) | No |

> **Note:** The `data/raw/` and `data/processed/` directories are excluded from version control via `.gitignore`. The processed dataset is re-created from the raw CSV by running `code/main.sh`.

---

## Computational Requirements

### Software Requirements

| Software | Version | Purpose |
|---|---|---|
| Stata/SE | 18 (or higher) | Data cleaning and analysis |
| `esttab` / `estout` | ≥ 2.0 | Summary-statistics tables (install via `ssc install estout`) |
| Bash | ≥ 3.2 | Pipeline orchestration (`code/main.sh`) |
| LaTeX (pdfLaTeX) | TeX Live 2023 or later | Compiling the paper |

**Stata packages.** The following user-written Stata packages are required and can be installed from SSC:

```stata
ssc install estout
```

### Memory and Runtime

| Machine | Cores | RAM | Approximate runtime |
|---|---|---|---|
| Apple M4 MacBook Pro (14-core) | 14 | ≥ 64 GB | ~17 hours |
| Linux cluster node | 4 | ≥ 60 GB (60 GB requested) | ~21.5 hours |

Peak virtual memory during execution is approximately **163 GB** (driven by the permutation test). The cluster job script at the top of `code/main.sh` requests `m_mem_free=60G` with a 48-hour wall-clock limit; adjust these values to match your environment.

### Controlled Randomness

[If the analysis uses random seeds, document them here. If not applicable, write: "No random seeds are used."]

---

## Description of Programs / Code

```
code/
├── main.sh                  # Master script — runs the full pipeline end-to-end
├── datasetMerging.do        # Imports raw CSV and saves processed Stata dataset
├── analysis.do              # Loads processed data, computes statistics, writes outputs
└── scalars/
    └── scalar_utils.do      # Utilities: save_scalar / read_scalar for LaTeX integration
```

| Script | Description |
|---|---|
| `code/main.sh` | Orchestrates the full pipeline: cleans output directories, then runs `datasetMerging.do` and `analysis.do` in sequence, logging all output to `output/logs/make.log`. Must be executed from the `code/` directory. |
| `code/datasetMerging.do` | Imports `super_tender_analytics_criteria_202602121648.csv` from `$WONDERFUL_DROPBOX_PATH/raw/`, performs cleaning, and saves `data/processed/main.dta`. |
| `code/analysis.do` | Loads the processed dataset, computes all paper statistics (e.g., `wonderfulConstant`), generates `output/scalars.tex` (inline numbers) and `output/summaryTable.tex` (Table 1). |
| `code/scalars/scalar_utils.do` | Defines `save_scalar` and `read_scalar` helper programs used to pass computed scalars from Stata directly into LaTeX `\newcommand` definitions. |
| `refresh_output.sh` | Copies files from `output/` into `writeup/paper/output/` (and generates `_tabonly.tex` variants) so that the LaTeX paper can find up-to-date results. Run this after `code/main.sh` completes and before recompiling the paper. |

---

## Instructions to Replicators

### 1. Obtain the raw data

Place the raw data file at:

```
$WONDERFUL_DROPBOX_PATH/raw/super_tender_analytics_criteria_202602121648.csv
```

See the **Data Availability** section above for how to obtain this file.

### 2. Set environment variables

Set the following shell environment variables before running any code:

```bash
export WONDERFUL_PROJECT_PATH=/path/to/this/repository   # absolute path to repo root
export WONDERFUL_DROPBOX_PATH=/path/to/your/dropbox      # path containing raw/ data folder
export STATABIN=stata-se                                  # Stata executable (default: stata-se)
```

### 3. Install required Stata packages

```stata
ssc install estout
```

### 4. Run the analysis

From the `code/` directory, execute the master script:

```bash
cd code
bash main.sh
```

This will:
1. Delete and recreate `data/processed/` and `output/`.
2. Run `datasetMerging.do` to produce `data/processed/main.dta`.
3. Run `analysis.do` to produce `output/scalars.tex` and `output/summaryTable.tex`.
4. Write a timestamped log to `output/logs/make.log`.

### 5. Copy outputs to the paper directory

From the repository root:

```bash
bash refresh_output.sh
```

### 6. Compile the paper

```bash
cd writeup/paper
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

The compiled paper will be `writeup/paper/main.pdf`.

---

## List of Tables and In-Text Numbers

| Output | File produced | Script | Location in paper |
|---|---|---|---|
| Table 1: Summary Statistics | `output/summaryTable.tex` | `code/analysis.do` | Section 2 (Data) |
| `\wonderfulConstant` (inline scalar) | `output/scalars.tex` | `code/analysis.do` | Abstract, Section 1 |

---

## Acknowledgements

[Optional: acknowledge data providers, funding sources, or research assistants here.]

---

*README last updated: [DATE]. Prepared following the [AEA Data and Code Availability Policy](https://www.aeaweb.org/journals/data/data-code-policy) and the [Social Science Data Editors' README template](https://social-science-data-editors.github.io/template_README/).*

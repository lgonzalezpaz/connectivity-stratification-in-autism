PY ?= python3

.PHONY: all theory data analysis extras figures refs clean
all: data analysis figures refs

theory:
	$(PY) code/03_theory.py

data:
	$(PY) code/01_index_and_download.py
	$(PY) code/02_extract_qc_and_timeseries.py
	$(PY) code/04_build_connectomes.py
	$(PY) code/05_phenotype.py
	$(PY) code/11a_download_abide1.py

analysis:
	$(PY) code/06_subtyping_and_reliability.py
	$(PY) code/07_longitudinal.py
	$(PY) code/10_identifiability.py
	$(PY) code/11b_abide1_replication.py
	$(PY) code/08_design_calculator.py
	$(PY) code/13_addenda.py

extras:
	$(PY) code/14_nda_catalogue.py
	$(PY) code/15_corr_download.py
	$(PY) code/16_decorrelation.py

figures:
	$(PY) code/12_figures.py

refs:
	$(PY) code/09_verify_references.py

clean:
	rm -rf data/conn_*.npy data/ts_* figures/*.pdf figures/*.png

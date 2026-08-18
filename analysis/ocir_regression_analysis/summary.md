# Analysis Notebook: OCIR ~ Group (Bayesian Regression)

**Regression Formula:** `ocir ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-18

## 1. Hypotheses
* Does mean OCIR (Obsessive-Compulsive Inventory-Revised) score differ between the ADHD and TD (typically developing) groups?

## 2. Variables
* **Outcome (y):** `ocir` - OCI-R score, raw scale, range 0-72.
* **Predictor (x):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw ocir scale.

## 3. Priors (user-approved)
* `Intercept ~ normal(14, 10)` - TD mean, weakly informative, anchored to this project's own existing OCIR descriptives which show TD mean ~13.8.
* `b_group ~ normal(0, 10)` - ADHD - TD difference.
* `sigma ~ exponential(0.1)`

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* `backend = "rstan"` - given value per this repo's precedent (cmdstanr confirmed unusable on this machine; already worked around identically in `aq_regression_analysis` and `bdi_regression_analysis`).

## 5. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` in this file - no extra filtering needed.
* Rows with missing `ocir` dropped (ASSUMED: no exclusion criterion given).

## 6. Clinical Cutoff
* OCI-R cutoff = 21 (established elsewhere in this project, in `analysis/trial_analysis/code/plot_ocir_stripplot_raw.R`), the boundary between "below clinical threshold" and "at or above clinical threshold".

## 7. Figure
* One composite figure (`output/regression_results.pdf`/`.png`), 3 tagged panels:
  * **A** (left): jittered raw `ocir` by group, shaded background bands for the OCI-R cutoff of 21 (0-21 vs 21-72), dashed cutoff line, posterior group-mean predictions (median + 90% CI, `posterior_epred()`) overlaid on the raw data.
  * **B** (top right): effect posterior of `b_group` (ADHD - TD).
  * **C** (bottom right, sub-panel): posterior ratio of ADHD mean / TD mean (null value = 1; `pd` for this panel is defined relative to 1 rather than 0 per the given specification, consistent with `aq_regression_analysis`'s and `bdi_regression_analysis`'s precedent).

## 8. Diagnostics
* `output/diagnostic.pdf`: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per `02_diagnostics.md`.

## 9. Findings / Summary
* (Leave this section blank until the model is completely fitted and evaluated).

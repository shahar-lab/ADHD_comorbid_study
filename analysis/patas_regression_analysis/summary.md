# Analysis Notebook: PATAS ~ Group (Bayesian Regression)

**Regression Formula:** `patas_sum ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-25

## 1. Hypotheses
* Does mean PATAS score differ between the ADHD and TD (typically developing) groups?

## 2. Variables
* **Outcome (y):** `patas_sum` - PATAS score, raw scale, observed range 0-42.
* **Predictor (x):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw patas_sum scale.

## 3. Priors (user-approved)
* `Intercept ~ normal(16, 10)`
* `b_group ~ normal(0, 12)`
* `sigma ~ exponential(0.1)`

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* `backend = "rstan"` - specified directly (per project convention, cmdstanr is not usable on this machine; also the established precedent in every sibling analysis: aq/bdi/ocir_regression_analysis).

## 5. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` in this file - no extra filtering needed.
* Rows with missing `patas_sum` dropped, per specification.
* `patas_sum` has far fewer non-missing values than the other measures in this dataset (~194 of 465 subjects), so the regression sample here is noticeably smaller, and the posterior/CI correspondingly wider, than in the aq/bdi/ocir analyses. This is expected given the data, not a bug.

## 6. Clinical cutoff
* Unlike `aq`, PATAS has no established clinical cutoff in this project. Accordingly this analysis has no cutoff-band/line on panel A, no cutoff-proportion panel, and no `summarize_cutoff_proportions.R` step - only the three-panel structure (A/B/C), matching the aq_regression_analysis pattern from before Panel D was added.

## 7. Figure
* One composite figure (`output/regression_results.pdf`/`.png`), 3 tagged panels:
  * **A** (left): jittered raw `patas_sum` by group, posterior group-mean predictions (median + 90% CI, `posterior_epred()`) overlaid on the raw data. No cutoff shading (see Section 6). Y-axis limit set to the next multiple of 5 above the observed max `patas_sum` (ASSUMED: no documented instrument max for PATAS).
  * **B** (top right): effect posterior of `b_group` (ADHD - TD).
  * **C** (bottom right, sub-panel): posterior ratio of ADHD mean / TD mean (null value = 1; ASSUMED: `pd` for this panel is defined relative to 1 rather than 0, adapting the effect-posterior annotation convention).

## 8. Diagnostics
* `output/diagnostic.pdf`: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per `02_diagnostics.md`.

## 9. Findings / Summary
* (Leave this section blank until the model is completely fitted and evaluated).

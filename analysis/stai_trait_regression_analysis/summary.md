# Analysis Notebook: STAI-Trait ~ Group (Bayesian Regression)

**Regression Formula:** `stai_trait ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-25

## 1. Hypotheses
* Does mean STAI-Trait (State-Trait Anxiety Inventory, trait subscale) score differ between the ADHD and TD (typically developing) groups?

## 2. Variables
* **Outcome (y):** `stai_trait` - STAI-Trait score, 20 items scored 0-3 in this dataset, raw scale, range 0-60.
* **Predictor (x):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw stai_trait scale.

## 3. Priors (user-approved)
* `Intercept ~ normal(16, 10)` - TD mean, weakly informative, anchored to the STAI-Trait 0-60 scale.
* `b_group ~ normal(0, 12)` - ADHD - TD difference.
* `sigma ~ exponential(0.08)`

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* `backend = "rstan"` - specified directly (cmdstanr is not usable on this machine); established precedent used in every sibling analysis (`aq_regression_analysis`, `bdi_regression_analysis`, `ocir_regression_analysis`).

## 5. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` in this file - no extra filtering needed.
* Rows with missing `stai_trait` dropped, as specified directly.

## 6. Figure
* One composite figure (`output/regression_results.pdf`/`.png`), 4 tagged panels:
  * **A** (left): jittered raw `stai_trait` by group, shaded background bands for the STAI-Trait clinical cutoff (44), dashed cutoff line, posterior group-mean predictions (median + 90% CI, `posterior_epred()`) overlaid on the raw data.
  * **B** (top right): effect posterior of `b_group` (ADHD - TD).
  * **C** (middle right, sub-panel): posterior ratio of ADHD mean / TD mean (null value = 1; ASSUMED: `pd` for this panel is defined relative to 1 rather than 0, adapting the effect-posterior annotation convention).
  * **D** (bottom right, sub-panel): posterior proportion of each group above the clinical cutoff (44), model-implied via each draw's group mean and residual sigma.

## 7. Diagnostics
* `output/diagnostic.pdf`: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per `02_diagnostics.md`.

## 8. Cutoff proportions
* `output/cutoff_proportion_summary.csv`: median + 90% CI of the model-implied proportion above cutoff (44), per group.

## 9. Note on cutoff value
* This analysis uses `cutoff_raw <- 44` for STAI-Trait, as given directly by the user for this analysis. `analysis/trial_analysis/code/prep_stai_trait_severity.R` elsewhere in this repo uses a STAI-Trait cutoff of 40 for a different purpose — flagged here in case the discrepancy is not intentional.

## 10. Findings / Summary
* (Leave this section blank until the model is completely fitted and evaluated).

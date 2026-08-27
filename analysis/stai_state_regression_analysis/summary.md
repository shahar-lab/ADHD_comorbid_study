# Analysis Notebook: STAI-State ~ Group (Bayesian Regression)

**Regression Formula:** `stai_state ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-25

## 1. Hypotheses
* Does mean STAI-State (State-Trait Anxiety Inventory, state subscale) score differ between the ADHD and TD (typically developing) groups?

## 2. Variables
* **Outcome (y):** `stai_state` - STAI-State score, 20 items scored 0-3 in this dataset, raw scale, range 0-60.
* **Predictor (x):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw stai_state scale.

## 3. Priors (user-approved)
* `Intercept ~ normal(15, 10)` - TD mean, weakly informative, anchored to the STAI-State 0-60 scale.
* `b_group ~ normal(0, 12)` - ADHD - TD difference.
* `sigma ~ exponential(0.08)`

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* `backend = "rstan"` - given/specified directly (per spec), used because cmdstanr is not usable on this machine, consistent with every sibling analysis (`aq_regression_analysis`, `bdi_regression_analysis`, `ocir_regression_analysis`).

## 5. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` in this file - no extra filtering needed.
* Rows with missing `stai_state` dropped, per spec.

## 6. Figure
* One composite figure (`output/regression_results.pdf`/`.png`), 4 tagged panels:
  * **A** (left): jittered raw `stai_state` by group, shaded background bands for the STAI-State clinical cutoff (40), dashed cutoff line, posterior group-mean predictions (median + 90% CI, `posterior_epred()`) overlaid on the raw data.
  * **B** (top right): effect posterior of `b_group` (ADHD - TD).
  * **C** (middle right, sub-panel): posterior ratio of ADHD mean / TD mean (null value = 1; ASSUMED: `pd` for this panel is defined relative to 1 rather than 0, adapting the effect-posterior annotation convention).
  * **D** (bottom right, sub-panel): posterior proportion of each group above the clinical cutoff (40), model-implied via each draw's group mean and residual sigma.

## 7. Diagnostics
* `output/diagnostic.pdf`: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per `02_diagnostics.md`.

## 8. Cutoff proportions
* `output/cutoff_proportion_summary.csv`: median + 90% CI of the model-implied proportion above cutoff (40), per group.

## 9. Findings / Summary
* (Leave this section blank until the model is completely fitted and evaluated).

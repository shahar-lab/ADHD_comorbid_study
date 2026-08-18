# Analysis Notebook: BDI ~ Group (Bayesian Regression)

**Regression Formula:** `bdi ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-15

## 1. Hypotheses
* Does mean BDI (Beck Depression Inventory-II) score differ between the ADHD and TD (typically developing) groups?

## 2. Variables
* **Outcome (y):** `bdi` - BDI-II score, raw scale, range 0-63.
* **Predictor (x):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw bdi scale.

## 3. Priors (user-approved)
* `Intercept ~ normal(10, 10)` - TD mean, weakly informative, anchored to the BDI-II scale.
* `b_group ~ normal(0, 10)` - ADHD - TD difference.
* `sigma ~ exponential(0.1)`

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* `backend = "rstan"` - cmdstanr is not usable on this machine (`cmdstanr::cmdstan_path()` unset, fails on a toolchain version-check mismatch; already confirmed and worked around in `aq_regression_analysis`). rstan itself works fine on this machine, so `backend = "rstan"` was used directly per `01_sampling_and_priors.md`'s "use cmdstanr if available" instruction.

## 5. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` in this file - no extra filtering needed.
* Rows with missing `bdi` dropped (ASSUMED: no exclusion criterion given).

## 6. Clinical Cutoff
* BDI-II cutoff = 14 (user-given), the boundary this project has previously used between "minimal" and "mild" depression severity categories.

## 7. Figure
* One composite figure (`output/regression_results.pdf`/`.png`), 3 tagged panels:
  * **A** (left): jittered raw `bdi` by group, shaded background bands for the BDI-II cutoff of 14 (0-14 vs 14-63), dashed cutoff line, posterior group-mean predictions (median + 90% CI, `posterior_epred()`) overlaid on the raw data.
  * **B** (top right): effect posterior of `b_group` (ADHD - TD).
  * **C** (bottom right, sub-panel): posterior ratio of ADHD mean / TD mean (null value = 1; ASSUMED: `pd` for this panel is defined relative to 1 rather than 0, adapting the effect-posterior annotation convention, consistent with `aq_regression_analysis`'s precedent).

## 8. Diagnostics
* `output/diagnostic.pdf`: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per `02_diagnostics.md`.

## 9. Findings / Summary
* (Leave this section blank until the model is completely fitted and evaluated).

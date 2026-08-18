# Analysis Notebook: AQ ~ Group (Bayesian Regression)

**Regression Formula:** `aq ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-08

## 1. Hypotheses
* Does mean AQ (Autism Spectrum Quotient) differ between the ADHD and TD (typically developing) groups?

## 2. Variables
* **Outcome (y):** `aq` - AQ-50 score, raw scale, range 0-50.
* **Predictor (x):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw aq scale.

## 3. Priors (user-approved)
* `Intercept ~ normal(20, 10)` - TD mean, weakly informative, anchored to the AQ-50 scale.
* `b_group ~ normal(0, 10)` - ADHD - TD difference.
* `sigma ~ exponential(0.1)`

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* `backend = "rstan"` - ASSUMED: cmdstanr is not usable on this machine (`cmdstanr::cmdstan_path()` unset, `install_cmdstan()` fails on a toolchain version-check mismatch). Substituted brms's rstan backend per `01_sampling_and_priors.md`'s "use cmdstanr if available" instruction.

## 5. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` in this file - no extra filtering needed.
* Rows with missing `aq` dropped (ASSUMED: no exclusion criterion given).

## 6. Figure
* One composite figure (`output/regression_results.pdf`/`.png`), 3 tagged panels:
  * **A** (left): jittered raw `aq` by group, shaded background bands for the AQ-32 clinical cutoff, dashed cutoff line, posterior group-mean predictions (median + 90% CI, `posterior_epred()`) overlaid on the raw data.
  * **B** (top right): effect posterior of `b_group` (ADHD - TD).
  * **C** (bottom right, sub-panel): posterior ratio of ADHD mean / TD mean (null value = 1; ASSUMED: `pd` for this panel is defined relative to 1 rather than 0, adapting the effect-posterior annotation convention).

## 7. Diagnostics
* `output/diagnostic.pdf`: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per `02_diagnostics.md`.

## 8. Findings / Summary
* (Leave this section blank until the model is completely fitted and evaluated).

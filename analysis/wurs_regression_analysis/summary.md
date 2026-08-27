# Analysis Notebook: WURS ~ Group (Bayesian Regression)

**Regression Formula:** `wurs ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-25

## 1. Hypotheses
* Does mean WURS (Wender Utah Rating Scale, retrospective childhood ADHD symptoms) score differ between the ADHD and TD (typically developing) groups?

## 2. Variables
* **Outcome (y):** `wurs` - WURS-25 sum score (25 items, each 0-4), raw scale, theoretical range 0-100.
* **Predictor (x):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw wurs scale.

## 3. Priors (user-approved)
* `Intercept ~ normal(13, 10)` - TD mean, weakly informative, anchored to the WURS-25 scale.
* `b_group ~ normal(0, 20)` - ADHD - TD difference.
* `sigma ~ exponential(0.06)`

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234 (specified).
* `backend = "rstan"` (specified) - cmdstanr is not usable on this machine (`cmdstanr::cmdstan_path()` unset, `install_cmdstan()` fails on a toolchain version-check mismatch), same precedent used in every sibling regression analysis.

## 5. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` in this file - no extra filtering needed.
* Rows with missing `wurs` dropped (specified: `filter(!is.na(wurs))`).

## 6. Figure
* One composite figure (`output/regression_results.pdf`/`.png`), 4 tagged panels:
  * **A** (left): jittered raw `wurs` by group, shaded background bands for the WURS-36 clinical cutoff, dashed cutoff line, posterior group-mean predictions (median + 90% CI, `posterior_epred()`) overlaid on the raw data.
  * **B** (top right): effect posterior of `b_group` (ADHD - TD).
  * **C** (middle right, sub-panel): posterior ratio of ADHD mean / TD mean (null value = 1; ASSUMED: `pd` for this panel is defined relative to 1 rather than 0, adapting the effect-posterior annotation convention).
  * **D** (bottom right): model-implied posterior proportion of each group scoring above the WURS-36 clinical cutoff.

## 7. Diagnostics
* `output/diagnostic.pdf`: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per `02_diagnostics.md`.

## 8. Numeric Summary
* `output/cutoff_proportion_summary.csv`: median + 90% CI of the posterior proportion above the WURS-36 cutoff, per group.

## 9. Findings / Summary
* (Leave this section blank until the model is completely fitted and evaluated).

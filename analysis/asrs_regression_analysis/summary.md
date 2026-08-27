# Analysis Notebook: ASRS ~ Group (Bayesian Regression)

**Regression Formula:** `asrs ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-25

## 1. Hypotheses
* Does mean ASRS (Adult ADHD Self-Report Scale) score differ between the ADHD and TD (typically developing) groups?

## 2. Variables
* **Outcome (y):** `asrs` - 0-4 scored 18-item ASRS-v1.1 sum, raw scale, theoretical range 0-72.
* **Predictor (x):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw asrs scale.

## 3. Priors (user-approved)
* `Intercept ~ normal(18, 10)` - TD mean, weakly informative, anchored to the 0-72 ASRS scale.
* `b_group ~ normal(0, 15)` - ADHD - TD difference.
* `sigma ~ exponential(0.08)`

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* `backend = "rstan"` - given/specified directly (per spec), since cmdstanr is not usable on this machine (`cmdstanr::cmdstan_path()` unset, `install_cmdstan()` fails on a toolchain version-check mismatch), matching the same substitution already established in every sibling regression analysis (aq/bdi/ocir) per `01_sampling_and_priors.md`'s "use cmdstanr if available" instruction.

## 5. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` in this file - no extra filtering needed.
* Rows with missing `asrs` dropped, per spec.

## 6. Figure
* One composite figure (`output/regression_results.pdf`/`.png`), 4 tagged panels:
  * **A** (left): jittered raw `asrs` by group, shaded background bands for the ASRS-40 clinical cutoff, dashed cutoff line, posterior group-mean predictions (median + 90% CI, `posterior_epred()`) overlaid on the raw data.
  * **B** (top right): effect posterior of `b_group` (ADHD - TD).
  * **C** (middle right): posterior ratio of ADHD mean / TD mean (null value = 1; ASSUMED: `pd` for this panel is defined relative to 1 rather than 0, adapting the effect-posterior annotation convention).
  * **D** (bottom right): posterior proportion of each group scoring above the clinical cutoff (`output/cutoff_proportion_summary.csv` gives the numeric median + 90% CI per group).

## 7. Diagnostics
* `output/diagnostic.pdf`: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per `02_diagnostics.md`.

## 8. Findings / Summary
* (Leave this section blank until the model is completely fitted and evaluated).

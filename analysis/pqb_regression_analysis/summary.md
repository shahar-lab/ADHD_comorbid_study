# Analysis Notebook: PQ-B ~ Group (Bayesian Regression)

**Regression Formula:** `pqb ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-25

## 1. Hypotheses
* Does mean PQ-B (Prodromal Questionnaire-Brief) item-endorsement count differ between the ADHD and TD (typically developing) groups?

## 2. Variables
* **Outcome (y):** `pqb` - PQ-B item-endorsement count, raw scale, theoretical range 0-21 (21-item measure). The separate `pqb_distress` column is not used.
* **Predictor (x):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw pqb scale.

## 3. Priors (user-approved)
* `Intercept ~ normal(2, 5)` - TD mean, weakly informative, anchored to the PQ-B 0-21 item-count scale.
* `b_group ~ normal(0, 5)` - ADHD - TD difference.
* `sigma ~ exponential(0.25)`

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* `backend = "rstan"` - specified directly by the approved spec's `brm()` call (card SPECIFICATION item 2); cmdstanr is not usable on this machine (established precedent from every sibling regression analysis: aq/bdi/ocir).


## 5. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` in this file - no extra filtering needed.
* Rows with missing `pqb` dropped, per specification.

## 6. Figure
* One composite figure (`output/regression_results.pdf`/`.png`), 4 tagged panels:
  * **A** (left): jittered raw `pqb` by group, shaded background bands for the PQ-B clinical cutoff (raw score of 7), dashed cutoff line, posterior group-mean predictions (median + 90% CI, `posterior_epred()`) overlaid on the raw data.
  * **B** (top right): effect posterior of `b_group` (ADHD - TD).
  * **C** (middle right, sub-panel): posterior ratio of ADHD mean / TD mean (null value = 1; ASSUMED: `pd` for this panel is defined relative to 1 rather than 0, adapting the effect-posterior annotation convention).
  * **D** (bottom right): posterior proportion of each group above the clinical cutoff (raw score of 7), model-implied via each posterior draw's group mean and residual sigma.

## 7. Diagnostics
* `output/diagnostic.pdf`: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per `02_diagnostics.md`.
* `output/cutoff_proportion_summary.csv`: median + 90% CI proportion above cutoff per group.

## 8. Findings / Summary
* (Leave this section blank until the model is completely fitted and evaluated).

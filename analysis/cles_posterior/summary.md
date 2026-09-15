# Analysis Notebook: Bayesian Common Language Effect Size (CLES) from Existing Posteriors

**Formula:** `CLES = P(Y_ADHD > Y_TD) = Phi(b_group_declaredADHD / (sqrt(2) * sigma))`, per posterior draw.
**Date Created:** 2026-09-02

## 1. Hypotheses / purpose

Quantifies, for each of 9 questionnaires, the probability that a randomly drawn ADHD-population
score exceeds a randomly drawn TD-population score — both from the posterior (parameter
uncertainty propagated) and from the raw observed data (a direct empirical statistic). No model
is fit here: this folder reuses the already-fitted, already-approved homoskedastic (single shared
`sigma`) `model_fit.rds` from each sibling `analysis/*_regression_analysis/` folder, plus each
sibling's `df_regression.rds` for the observed-data comparison.

This is **not** the same statistic as `analysis/cles/`, which computes a Welch-type (per-group
`sigma`, heteroskedastic) CLES from separately-fit distributional models. This folder's CLES
assumes one shared `sigma` across both groups, matching the original regression models' own
`family = gaussian()` specification (no distributional formula).

## 2. Variables

* **Outcome (per measure):** `aq`, `asrs`, `wurs`, `bdi`, `ocir`, `pqb`, `stai_state`,
  `stai_trait`, `icar` — raw questionnaire score, read from each sibling's `df_regression.rds`.
* **Predictor:** `group_declared` (factor, TD = reference, ADHD = comparison), as fit in each
  sibling model.
* **Posterior draws used:** 4000 per outcome (chains = 4, iter = 2000, warmup = 1000) — below
  the 10,000-draw target, so all available draws are used and the actual count is reported.
  PATAS is excluded (its sibling `analysis/patas_regression_analysis/` folder is not present in
  this repo's working tree).

## 3. Methodology notes

* CLES is computed separately for **every** posterior draw, never from a single point-estimate
  (median/mean) of `b_Intercept`, `b_group_declaredADHD`, or `sigma`.
* No synthetic participants are generated and no residual noise is added — posterior parameter
  uncertainty is propagated directly via the closed-form normal-difference formula.
* Observed CLES is computed via the full ADHD × TD pairwise comparison (`outer()`), not by
  sampling pairs — feasible at these sample sizes (verified: pairwise count = ADHD N × TD N for
  every outcome).
* Direction is always ADHD > TD; a measure where ADHD scores lower than TD (e.g. ICAR) shows
  CLES < 0.50 naturally, never flipped or relabeled.
* Sanity checks (posterior CLES in [0,1], CrI ordered correctly, P(CLES > 0.50) in [0,1],
  observed CLES in [0,1], pairwise count = ADHD N × TD N) are run and reported per outcome and
  overall in the console output from `code/build_summary_table.R`.

## 4. Interpretation

* **Observed CLES** = proportion of actual observed ADHD–TD pairs where the ADHD participant
  scored higher (ties = 0.5) — a direct empirical statistic on the real data only.
* **Posterior CLES** = the posterior probability that a randomly drawn ADHD-population score
  exceeds a randomly drawn TD-population score, integrating parameter uncertainty from the
  fitted model. It is never a p-value, and never "the probability the null hypothesis is false."

## 5. Outputs

* `output/cles_posterior_draws.csv` — full long-format posterior CLES draws, all 9 outcomes.
* `output/cles_summary.csv` — one row per outcome: Measure, ADHD N, TD N, Observed CLES,
  Posterior Median/Mean/SD CLES, 95% CrI, P(CLES > 0.50), posterior draws used.
* `output/cles_diagnostics.pdf` / `.png` — Panel A (per-measure posterior CLES distributions,
  faceted, median + 95% CrI + 0.50 reference line) and Panel B (observed vs. posterior CLES,
  forest-plot layout across all 9 measures).

## 6. Findings / Summary
* (Leave this section blank until `main.R` has been run and the outputs reviewed).

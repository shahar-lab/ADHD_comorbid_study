# Analysis Notebook: Bayesian T-Test (AQ by Group)

**Model:** Bayesian independent-samples t-test, `aq ~ group_declared` (ADHD vs TD)
**Date Created:** 2026-08-04 (revised after code review)

## 1. Hypotheses
Do ADHD and TD participants differ in Autism Quotient (AQ) score, and if so, in which direction?

## 2. Variables
* **Outcome:** `aq` (Autism Quotient)
* **Predictor:** `group_declared`, filtered to `ADHD` / `TD` only, factor levels `c("ADHD", "TD")`
* **Data source:** `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (object `df_remove_diagnosis_contradiction`)
* **N:** 429 (ADHD = 206, TD = 223), non-missing `aq` only

## 3. Method / Toolchain
Two tools, used for two different numbers (kept explicit throughout the code and console output):

* **`BayesFactor::ttestBF`** — default JZS Cauchy prior (`rscale = "medium"`), two-sided, unrestricted alternative (no `nullInterval`). Produces **BF10 / BF01** only.
* **`BayesFactor::posterior()`** on the same `bf_object`, run as **4 independent chains x 2500 iterations** (10,000 pooled draws total) from the identical JZS model, so the effect-size posterior is fully consistent with BF10/BF01. This is the source of the **posterior d + 95% credible interval**, the posterior plot, and (via the 4-chain structure) the mandatory MCMC diagnostics. A `brms` group-predictor model was considered per the `bayesian-regression` skill but was not used — `BayesFactor::posterior()` already yields `delta` directly from the same model as BF10, without needing a separate formula/prior/plan approval cycle.
* **Sign convention is checked in executable code, not just asserted**: `code/report_results.R` computes raw group means and confirms `sign(mean(ADHD) - mean(TD))` matches `sign(median(delta))` before any directional claim is printed. With `group_declared` levels `c("ADHD", "TD")`, `BayesFactor` labels the contrast `"beta (ADHD - TD)"`; the check confirms `delta` follows the same direction (positive = higher AQ in ADHD).
* **MCMC diagnostics** (`code/diagnostics.R`, mandatory per `bayesian-regression` skill's `02_diagnostics.md`): rhat/ess_bulk/ess_tail summary table, trankplot (`mcmc_rank_overlay`), pairs plot (`mcmc_pairs`), built from the 4-chain draws array and saved as `output/diagnostic.pdf`. All rhat = 1.00; ess_bulk/ess_tail ~9,000-10,000 for every parameter (mu, beta, sig2, delta, g); trankplot shows well-mixed, overlapping chains.

## 4. Findings / Summary

| Quantity | Value | Source |
|---|---|---|
| BF10 | 3.64 x 10^22 | `BayesFactor::ttestBF` |
| BF01 | 2.75 x 10^-23 | `BayesFactor::ttestBF` |
| Posterior median delta (Cohen's d, ADHD - TD) | 1.069 | `BayesFactor::posterior()`, 4 chains |
| 95% credible interval | [0.865, 1.270] | `BayesFactor::posterior()`, 4 chains |
| rhat (all parameters) | 1.00 | `posterior::summarise_draws()` |
| ess_bulk / ess_tail (delta) | ~9,200 / ~9,900 of 10,000 | `posterior::summarise_draws()` |
| Sign-convention check | PASS (ADHD mean 21.46 > TD mean 14.64, matches positive delta) | `report_results.R` executable check |

**Interpretation:** BF10 (default Cauchy prior, two-sided, unrestricted alternative) tests only whether the two groups differ *at all* -- it carries no information about direction. Directionality comes from the posterior delta: the 95% credible interval [0.865, 1.270] excludes zero and lies entirely on the positive (ADHD - TD) side, and this direction is confirmed against the raw group means in executable code (not just a comment). Read from the posterior, not from BF10: **ADHD participants show reliably higher AQ scores than TD participants**, with a large standardized effect (delta ~= 1.07).

Posterior plot: `output/posterior_delta.pdf`, `output/posterior_delta.png`.
MCMC diagnostics: `output/diagnostic.pdf`.

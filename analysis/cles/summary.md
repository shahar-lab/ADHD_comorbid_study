# Analysis Notebook: CLES / Common Language Effect Size (ADHD vs. TD)

**Model:** 10 separate heteroskedastic Bayesian regressions, one per questionnaire — `<score> ~ group_declared, sigma ~ group_declared` (distributional `brms` model, TD releveled as the reference level).
**Date Created:** 2026-08-31

## 1. Hypotheses
* For each of 10 questionnaires, how much more likely is a randomly drawn ADHD participant to score higher than a randomly drawn TD participant (Common Language Effect Size / probability of superiority), and how does that translate into an odds ("how many times more likely")?
* Reported alongside Cohen's d (standardized mean difference) and, for 8 of the 10 questionnaires with an established literature cutoff, the model-implied risk ratio of scoring above that cutoff.

## 2. Variables
* **Outcome:** the raw questionnaire score — `asrs`, `wurs`, `aq`, `stai_state`, `stai_trait`, `bdi`, `ocir`, `pqb`, `patas_sum` (PATAS), `icar`, one model per questionnaire.
* **Predictor (both submodels):** `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Mean submodel: Intercept = TD mean, `b` = ADHD − TD. Sigma submodel (log link): Intercept = log(TD SD), `b` = log(ADHD SD / TD SD).
* Domain grouping (used to order the output table): ADHD symptoms (ASRS, WURS), Autistic traits (AQ), Anxiety (STAI-State, STAI-Trait), Depression (BDI), Obsessive-Compulsive (OCI-R), Psychosis-related (PQ-B), Attitudes (PATAS), Cognitive ability (ICAR).

## 3. Why a new model per questionnaire, instead of reusing the sibling `*_regression_analysis/` fits
* The CLES formula (`Φ(diff / √(σ_ADHD² + σ_TD²))`) is Welch-type: it needs *separate* posterior SDs per group. Every sibling `*_regression_analysis/` folder in this repo fits a single shared sigma across both groups, so it can't supply that. This folder is self-contained and fits its own distributional model instead — the mean-submodel priors are reused verbatim from the already-approved sibling priors, but the sigma-submodel priors are new (see below).
* Does **not** reuse posterior draws, medians, or other saved objects from `analysis/*_regression_analysis/` or `analysis/auc/` — computed independently from the raw individual-level scores and `group_declared`.

## 4. Priors (user-approved)
Mean submodel — reused verbatim from each sibling model's already-approved priors:

| Questionnaire | Intercept (TD mean) | b (ADHD − TD) |
|---|---|---|
| ASRS | normal(18, 10) | normal(0, 15) |
| WURS | normal(13, 10) | normal(0, 20) |
| AQ | normal(20, 10) | normal(0, 10) |
| STAI-State | normal(15, 10) | normal(0, 12) |
| STAI-Trait | normal(16, 10) | normal(0, 12) |
| BDI | normal(10, 10) | normal(0, 10) |
| OCI-R | normal(14, 10) | normal(0, 10) |
| PQ-B | normal(2, 5) | normal(0, 5) |
| PATAS | normal(16, 10) | normal(0, 12) |
| ICAR | normal(9, 5) | normal(0, 5) |

Sigma submodel — new, weakly informative, log link (`dpar = "sigma"`): Intercept ~ `normal(log_mean, 0.5)` where `log_mean` = log of that questionnaire's sibling model's shared-sigma prior mean (`1/rate` of its `exponential(rate)` prior); `b` ~ `normal(0, 0.5)` for every questionnaire (weakly informative around no SD difference between groups).

## 5. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* `backend = "rstan"` — matches every sibling model in this repo (cmdstanr unusable on this machine).

## 6. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical processed dataframe, per this repo's CLAUDE.md).
* `group_declared` already contains only `ADHD`/`TD` — no extra filtering needed.
* Each questionnaire's model is fit on its own complete-case subset (non-missing `group_declared` and non-missing score on that questionnaire); N differs across questionnaires and is reported in `output/sample_sizes.csv`. No imputation.

## 7. Posterior quantities (per draw, per questionnaire)
* `diff = mu_ADHD − mu_TD`
* `CLES = Φ(diff / √(σ_ADHD² + σ_TD²))` — probability a random ADHD draw exceeds a random TD draw
* `Odds of Superiority = CLES / (1 − CLES)`
* `Cohen's d = diff / √((σ_ADHD² + σ_TD²) / 2)` — conventional averaged-pooled-SD denominator, deliberately different from CLES's (unaveraged) denominator
* `Risk Ratio = P(score ≥ cutoff | ADHD) / P(score ≥ cutoff | TD)`, model-implied via `pnorm(cutoff, mu, sigma, lower.tail = FALSE)` per group — only for ASRS, WURS, BDI, OCI-R, PQ-B, STAI-State, STAI-Trait, AQ (established literature cutoffs already used elsewhere in this repo: 40, 36, 14, 21, 7, 40, 44, 32 respectively). PATAS and ICAR have no established cutoff and are left blank.
* All four summarized as posterior median + 90% equal-tailed credible interval (`quantile(.05, .95)`), matching this repo's existing convention (not HDI).

## 8. Non-parametric cross-check
* `output/nonparametric_cles_crosscheck.csv`: the empirical Mann–Whitney-U-based CLES computed directly on the raw observed scores (`wilcox.test`'s `W` statistic / (N_ADHD × N_TD)), alongside the Bayesian posterior-median CLES, per questionnaire — a point estimate, not a posterior, and not a column in the main table. Included to confirm the two approaches agree in direction/magnitude; the formula's equivalence to a direct pairwise comparison was validated on AQ before being applied to all 10 questionnaires.

## 9. Outputs
* `output/cles_summary_table.csv` / `.md`: the main table — Domain | Measure | Posterior Difference (CrI) | Cohen's d (Median [CrI]) | CLES / P(X_ADHD > X_non) (Median [CrI]) | Common Language Odds (Median [CrI]) | Clinical Cutoff Risk Ratio (Median [CrI]).
* `output/sample_sizes.csv`: N, N_ADHD, N_TD per questionnaire (supplementary; not a main-table column, mirroring `analysis/auc`'s `roc_sample_sizes.csv` precedent).
* `output/diagnostic.pdf`: ess_bulk/ess_tail/rhat summary table, trankplot, and pairs plot for each of the 10 models, in domain-table order. Reported without interpretation, per `02_diagnostics.md`.
* `output/interpretation_note.md`: 1-2 sentence note on what the Odds of Superiority means and why it's comparable across questionnaires.

## 10. Findings / Summary
* (Leave this section blank until all 10 models have been fitted, diagnostics checked, and the outputs reviewed).

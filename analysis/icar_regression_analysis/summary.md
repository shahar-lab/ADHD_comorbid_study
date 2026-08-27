# Analysis Notebook: ICAR ~ Group (Bayesian Regression)

**Regression Formula:** `icar ~ group_declared` (TD releveled as the reference level)
**Date Created:** 2026-08-25

## 1. Hypotheses
* Does mean ICAR (International Cognitive Ability Resource, 16-item count-correct) differ between the ADHD and TD (typically developing) groups?
* Note: unlike the symptom-severity measures in the sibling analyses (aq/bdi/ocir), ICAR is a cognitive-ability score where a HIGHER value means BETTER performance, not greater severity. This affects interpretation/wording only, not the model structure.

## 2. Variables
* Outcome (y): `icar` — 16-item cognitive ability count-correct score, raw scale, theoretical range 0-16, higher = better ability.
* Predictor (x): `group_declared` (`ADHD` / `TD`), releveled so `TD` is the reference level. Intercept = TD mean; the `group_declared` coefficient (`b_group`) = ADHD - TD, already on the raw icar scale.

## 3. Priors (user-approved)
* Intercept ~ normal(9, 5) — TD mean, weakly informative, anchored to the ICAR-16 count-correct scale.
* b_group ~ normal(0, 5) — ADHD - TD difference.
* sigma ~ exponential(0.25)

## 4. Sampling
* 4 chains, iter = 2000, warmup = 1000, seed = 1234.
* backend = "rstan" — specified directly (per the established precedent in every sibling analysis: aq/bdi/ocir_regression_analysis), not an open assumption.

## 5. Data
* Source: data/processed_data/df_remove_diagnosis_contradiction.Rdata (canonical processed dataframe, per this repo's CLAUDE.md).
* group_declared already contains only ADHD/TD in this file — no extra filtering needed.
* Rows with missing icar dropped, per spec.

## 6. Figure
* One composite figure (output/regression_results.pdf/.png), 3 tagged panels A/B/C only. ICAR has no established clinical cutoff, so unlike the sibling aq/bdi/ocir analyses, no Panel D and no cutoff-proportion summary were produced for this measure.
* Panel A (left): jittered raw icar by group, posterior group-mean predictions (median + 90% CI, posterior_epred()) overlaid on the raw data. No cutoff shading or cutoff line.
* Panel B (top right): effect posterior of b_group (ADHD - TD).
* Panel C (bottom right, sub-panel): posterior ratio of ADHD mean / TD mean (null value = 1; ASSUMED: pd for this panel is defined relative to 1 rather than 0, adapting the effect-posterior annotation convention).

## 7. Diagnostics
* output/diagnostic.pdf: ess/rhat summary table, trankplot, pairs plot. Reported without interpretation, per 02_diagnostics.md.

## 8. Outcome
* To be filled in once the model is completely fitted and evaluated.

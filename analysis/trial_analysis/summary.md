# Analysis Notebook: Trial Analysis - Self-Report Measure Distributions

**Type:** Descriptive / exploratory (no regression model)
**Date Created:** 2026-07-23

## 1. Hypotheses
* No formal hypothesis test. Exploratory look at the distribution of three
  self-report measures (BDI, AQ, OCIR), split by declared group (ADHD vs TD).

## 2. Variables
* **Measures plotted:** `bdi`, `aq`, `ocir`
* **Group variable:** `group_declared` (values: `ADHD`, `TD`). Note: the
  canonical data column is named `group_declared`, not `declared_group`.

## 3. Data
* Source: `data/processed_data/df_remove_diagnosis_contradiction.Rdata` (canonical
  processed dataframe, same file used by `preprocessing/05_get_averages.R`).
* 464 rows total, all already `ADHD` (n=214) or `TD` (n=250) in this file -
  no other `group_declared` values (e.g. "undeclared") present at this stage.
* Missingness (of 214 ADHD / 250 TD):
  - bdi:  8 missing (ADHD), 26 missing (TD)
  - aq:   8 missing (ADHD), 27 missing (TD)
  - ocir: 12 missing (ADHD), 27 missing (TD)

## 4. Findings / Summary
* One multi-panel figure (3 panels: BDI, AQ, OCIR), each a Wilkinson-style
  stacked dot histogram, dots colored by group (ADHD = blue #0072B2,
  TD = vermillion/red #D55E00, Okabe-Ito colorblind-safe pair).
* Output: `output/selfreport_dothistograms.pdf` / `.png`.

## 5. Addition: BDI Severity Sub-Analysis (2026-07-29)

**Purpose:** classify each participant's BDI score into standard depression-severity
categories and visualize the ADHD/TD split on both the raw and a 0-100 rescaled axis.

**Data:** same source file (`data/processed_data/df_remove_diagnosis_contradiction.Rdata`),
built on top of the `df` object already produced by `prep_data.R` (ADHD n=214, TD n=250;
no additional group filtering). Rows with missing `bdi` are dropped for this
sub-analysis: 34 missing total (8 ADHD, 26 TD), leaving 430 rows (ADHD n=206, TD n=224).

**Transform:** `bdi_transformed = (bdi / 63) * 100` (63 = BDI-II theoretical max;
observed raw range in this data is 0-54).

**Severity categories** (`cut()` on the raw `bdi`, breaks `c(0, 13, 19, 28, 63)`,
`include.lowest = TRUE`, `right = TRUE`):
* 0-13: Minimal or no depression
* 14-19: Mild depression
* 20-28: Moderate depression
* 29-63: Severe depression

**Severity counts (ADHD / TD / Overall):**

| Group   | Minimal or no depression | Mild depression | Moderate depression | Severe depression |
|---------|---------------------------|------------------|----------------------|---------------------|
| ADHD (n=206) | 104 (50.5%) | 40 (19.4%) | 38 (18.4%) | 24 (11.7%) |
| TD (n=224)   | 193 (86.2%) | 20 (8.9%)  | 7 (3.1%)   | 4 (1.8%)   |
| Overall (n=430) | 297 (69.1%) | 60 (14.0%) | 45 (10.5%) | 28 (6.5%) |

**Descriptives (mean +/- SD):**

| Group | bdi (raw, 0-63) | bdi_transformed (0-100) |
|-------|------------------|--------------------------|
| ADHD (n=206) | 15.34 +/- 10.21 | 24.36 +/- 16.21 |
| TD (n=224)   | 7.01 +/- 6.66   | 11.13 +/- 10.57 |

**New files:**
* `code/prep_bdi_severity.R` - builds `df_bdi_severity` from `df` (drops missing
  `bdi`, adds `bdi_transformed` and the `bdi_severity` factor). Named
  `df_bdi_severity` rather than `df_bdi` deliberately, to avoid colliding with the
  local `df_bdi` object created inside `plot_selfreport_dothistograms.R`.
* `code/summarize_bdi_severity.R` - writes `output/bdi_severity_summary.csv`
  (counts + percentages by group and Overall) and
  `output/bdi_descriptives_summary.csv` (mean/SD for both scales, by group).
* `code/plot_bdi_stripplot_transformed.R` - `output/bdi_stripplot_transformed.pdf`/`.png`:
  jittered strip plot of `bdi_transformed` by `group_declared`, mean+/-SD point-range
  per group, dashed reference lines at the rescaled cutoffs (~20.63, ~30.16, ~44.44).
* `code/plot_bdi_stripplot_raw.R` - `output/bdi_stripplot_raw.pdf`/`.png`: same style,
  raw `bdi` (0-63 scale), reference lines at 13, 19, 28.
* Both strip plots use the same ADHD = #0072B2 / TD = #D55E00 color pair as the
  self-report dot-histogram figure above.

**Data-quality note:** missingness pattern for `bdi` matches what was already reported
in Section 2 (8 ADHD / 26 TD missing) - no discrepancy between the two sub-analyses.

## 6. Addition: STAI-Trait, STAI-State, ICAR - Distributions + Binary Severity Cutoffs (2026-08-01)

**Purpose:** extend the self-report battery covered by this folder with three more
measures - `stai_trait`, `stai_state`, `icar` - and, for the two STAI scores plus
the two measures already present (`ocir`, `aq`), add a binary (below/at-or-above
cutoff) clinical-severity classification, following the same shape as the BDI
sub-analysis in Section 5 but simplified (single cutoff, no rescaled-0-100 variant).

**Scope decisions (explicit, not oversights):**
* `icar` gets distribution-only treatment - no severity cutoff exists for it,
  since it is a cognitive-ability (reasoning) measure, not a symptom scale.
* `patas_sum` and `pqb` are **explicitly excluded** from this entire addition
  (and from this analysis folder generally) per user decision - not in
  `prep_data.R`'s `select()`, not in any figure, no severity treatment. This is
  a deliberate scope decision, not something left out by mistake.
* The combined `stai` column is not used anywhere in this folder - only the
  `stai_trait` / `stai_state` subscales.

**`prep_data.R` changes:** `select()` now also carries `stai_trait`, `stai_state`,
`icar`; `missing_report`'s `pivot_longer(cols = ...)` was extended to include all
three so the missingness printout stays accurate for every measure in `df`.

**Missingness (of 214 ADHD / 250 TD, same `df` as Section 2-3):**

| Measure    | ADHD missing | TD missing |
|------------|--------------|------------|
| stai_trait | 10           | 27         |
| stai_state | 10           | 27         |
| icar       | 12           | 27         |

**New distribution figure:** `code/plot_selfreport_dothistograms_2.R` - a second
3-panel Wilkinson-style stacked dot-histogram figure (STAI-Trait, STAI-State, ICAR),
same ADHD/TD colors (`#0072B2` / `#D55E00`), same `theme_minimal(base_size = 13)`,
patchwork assembly with panel tags A/B/C, legend collected at the bottom. Binwidths
chosen from each measure's observed range: 2 for STAI-Trait (observed 0-59) and
STAI-State (observed 0-57), 1 for ICAR (observed 0-16, a 16-item test). This is a
separate figure from `selfreport_dothistograms.pdf`/`.png` (Section 4), which is
untouched. Output: `output/selfreport_dothistograms_2.pdf` / `.png`.

**Severity cutoffs (binary: below vs at-or-above; the cutoff value itself belongs
to "at or above"):**

| Measure    | Cutoff | Basis |
|------------|--------|-------|
| stai_trait | 40     | Standard STAI-Trait elevated-anxiety threshold |
| stai_state | 40     | Standard STAI-State elevated-anxiety threshold |
| ocir       | 21     | Standard OCI-R clinical threshold |
| aq         | 32     | Standard AQ clinical threshold |

Implemented as `cut(x, breaks = c(-Inf, cutoff, Inf), right = FALSE, labels =
c("Below clinical cutoff", "At or above clinical cutoff"))` - `right = FALSE`
gives half-open intervals `[-Inf, cutoff)` / `[cutoff, Inf)`, so the cutoff value
itself lands in "At or above clinical cutoff".

**Severity counts (ADHD / TD / Overall), n = non-missing on that measure:**

| Measure (n non-missing) | ADHD below / at-or-above | TD below / at-or-above | Overall below / at-or-above |
|---|---|---|---|
| stai_trait (n=427, ADHD n=204, TD n=223) | 173 (84.8%) / 31 (15.2%) | 221 (99.1%) / 2 (0.9%) | 394 (92.3%) / 33 (7.7%) |
| stai_state (n=427, ADHD n=204, TD n=223) | 175 (85.8%) / 29 (14.2%) | 217 (97.3%) / 6 (2.7%) | 392 (91.8%) / 35 (8.2%) |
| ocir (n=425, ADHD n=202, TD n=223)       | 100 (49.5%) / 102 (50.5%) | 176 (78.9%) / 47 (21.1%) | 276 (64.9%) / 149 (35.1%) |
| aq (n=429, ADHD n=206, TD n=223)         | 191 (92.7%) / 15 (7.3%) | 221 (99.1%) / 2 (0.9%) | 412 (96.0%) / 17 (4.0%) |

**Descriptives (mean +/- SD, raw scale only - no transform for these 4 measures):**

| Measure | ADHD | TD |
|---|---|---|
| stai_trait | 26.30 +/- 12.50 (n=204) | 15.60 +/- 9.38 (n=223) |
| stai_state | 25.02 +/- 12.19 (n=204) | 15.35 +/- 10.48 (n=223) |
| ocir       | 23.15 +/- 12.95 (n=202) | 13.79 +/- 10.50 (n=223) |
| aq         | 21.51 +/- 6.72 (n=206)  | 14.60 +/- 5.85 (n=223) |

**Strip-plot y-axis limits** (theoretical/observed scale range, same convention
BDI used with its 0-63 theoretical max): stai_trait 0-60, stai_state 0-60
(observed max 59 / 57 respectively, consistent with a 0-3-per-item, 20-item scale),
ocir 0-72 (standard OCI-R max), aq 0-50 (standard AQ max).

**New files:**
* `code/plot_selfreport_dothistograms_2.R` - `output/selfreport_dothistograms_2.pdf`/`.png`:
  second 3-panel dot-histogram figure for stai_trait, stai_state, icar.
* `code/prep_stai_trait_severity.R` - builds `df_stai_trait_severity` from `df`
  (drops missing `stai_trait`, adds the binary `stai_trait_severity` factor).
* `code/summarize_stai_trait_severity.R` - writes `output/stai_trait_severity_summary.csv`
  and `output/stai_trait_descriptives_summary.csv`.
* `code/plot_stai_trait_stripplot_raw.R` - `output/stai_trait_stripplot_raw.pdf`/`.png`.
* `code/prep_stai_state_severity.R` - builds `df_stai_state_severity` from `df`
  (drops missing `stai_state`, adds the binary `stai_state_severity` factor).
* `code/summarize_stai_state_severity.R` - writes `output/stai_state_severity_summary.csv`
  and `output/stai_state_descriptives_summary.csv`.
* `code/plot_stai_state_stripplot_raw.R` - `output/stai_state_stripplot_raw.pdf`/`.png`.
* `code/prep_ocir_severity.R` - builds `df_ocir_severity` from `df` (drops missing
  `ocir`, adds the binary `ocir_severity` factor).
* `code/summarize_ocir_severity.R` - writes `output/ocir_severity_summary.csv` and
  `output/ocir_descriptives_summary.csv`.
* `code/plot_ocir_stripplot_raw.R` - `output/ocir_stripplot_raw.pdf`/`.png`.
* `code/prep_aq_severity.R` - builds `df_aq_severity` from `df` (drops missing
  `aq`, adds the binary `aq_severity` factor).
* `code/summarize_aq_severity.R` - writes `output/aq_severity_summary.csv` and
  `output/aq_descriptives_summary.csv`.
* `code/plot_aq_stripplot_raw.R` - `output/aq_stripplot_raw.pdf`/`.png`.
* All `df_<measure>_severity` objects are deliberately named to avoid colliding
  with the local `df_<measure>` objects built inside the two dot-histogram scripts
  (same convention as `df_bdi_severity` in Section 5).

**Untouched (out of scope for this addition):** `plot_selfreport_dothistograms.R`,
`prep_bdi_severity.R`, `summarize_bdi_severity.R`, `plot_bdi_stripplot_raw.R`,
`plot_bdi_stripplot_transformed.R`, and their outputs.

## 7. Addition: Transformed (0-100) Strip Plots for STAI-Trait, STAI-State, OCI-R, AQ (2026-08-03)

**Purpose:** extend the 0-100 rescaled strip-plot treatment that BDI already has
(Section 5) to the four measures added in Section 6 - `ocir`, `aq`, `stai_trait`,
`stai_state` - so all five symptom scales in this folder have a common 0-100
visual scale, in addition to their existing raw-scale strip plots.

**Rescale formulas (per measure, based on each instrument's theoretical range):**

| Measure    | Range | Min | Formula used |
|------------|--------------------|-----|--------------|
| ocir       | 0-72 (theoretical) | 0  | `ocir_transformed = (ocir / 72) * 100` |
| aq         | 0-50 (theoretical) | 0  | `aq_transformed = (aq / 50) * 100` |
| stai_trait | 0-60 (empirical) | 0 | `stai_trait_transformed = (stai_trait / 60) * 100` |
| stai_state | 0-60 (empirical) | 0 | `stai_state_transformed = (stai_state / 60) * 100` |

OCI-R and AQ have a theoretical minimum of 0 (same as BDI), so the same
zero-min shortcut (`x / max * 100`) used in `prep_bdi_severity.R` is
mathematically valid for them. STAI-Trait and STAI-State were initially
assumed to follow the standard 20-item STAI subscale (scored 1-4 per item,
range 20-80), which would have required the full min-max rescale
`(x - min) / (max - min) * 100`. That assumption was wrong for this dataset:
this dataset uses a 0-3-per-item STAI scoring convention (effective range
0-60), confirmed by the user and matching the range already used in the
already-approved raw strip plots (`plot_stai_trait_stripplot_raw.R`,
`plot_stai_state_stripplot_raw.R`, both `scale_y_continuous(limits = c(0, 60))`).
Since the empirical min is genuinely 0, the same zero-min shortcut used for
OCI-R/AQ/BDI applies here too: `x / 60 * 100`.

**Rescaled cutoffs (dashed reference lines on each transformed plot, labeled
with the original raw cutoff number, positioned at the rescaled y-value):**

| Measure    | Raw cutoff | Rescaled cutoff |
|------------|------------|------------------|
| ocir       | 21 | 21/72*100 ≈ 29.17 |
| aq         | 32 | 32/50*100 = 64 |
| stai_trait | 40 | 40/60*100 ≈ 66.67 |
| stai_state | 40 | 40/60*100 ≈ 66.67 |

**Descriptives on the transformed (0-100) scale (mean +/- SD by group):**

| Measure | ADHD | TD |
|---|---|---|
| ocir_transformed       | 32.14 +/- 18.02 (n=202) | 19.15 +/- 14.58 (n=223) |
| aq_transformed         | 42.98 +/- 13.44 (n=206) | 29.19 +/- 11.71 (n=223) |
| stai_trait_transformed | 43.9 +/- 20.8 (n=204) | 26.0 +/- 15.6 (n=223) |
| stai_state_transformed | 41.7 +/- 20.3 (n=204) | 25.4 +/- 17.4 (n=223) |

**Resolution of the earlier scale-mismatch (was an open problem, now
resolved):** the previous version of this section flagged a mismatch between
an assumed standard STAI range (20-80) and this dataset's actual observed
range (`stai_trait` spans 0-59, `stai_state` spans 0-57), which produced
negative transformed values for roughly half the sample and caused `ggplot2`
to silently clip those rows off the 0-100 plot axis ("Removed N rows"
warnings). The user has since confirmed this dataset uses a 0-3-per-item STAI
scoring convention (not the standard 1-4-per-item convention), giving a
genuine effective range of 0-60 - the same range already used in the
already-approved raw strip plots built earlier in this session. With the
formula corrected to `x / 60 * 100`, all ~427 non-missing rows per measure now
fall within [0, 100] and plot without clipping; re-running `main.R` produces
no "Removed N rows" warnings for either STAI plot. No discrepancy remains.

**New files:**
* `code/plot_ocir_stripplot_transformed.R` - `output/ocir_stripplot_transformed.pdf`/`.png`.
* `code/plot_aq_stripplot_transformed.R` - `output/aq_stripplot_transformed.pdf`/`.png`.
* `code/plot_stai_trait_stripplot_transformed.R` - `output/stai_trait_stripplot_transformed.pdf`/`.png`.
* `code/plot_stai_state_stripplot_transformed.R` - `output/stai_state_stripplot_transformed.pdf`/`.png`.
* `code/prep_ocir_severity.R` - modified to add `ocir_transformed` alongside the
  existing `ocir_severity` factor (no change to existing severity logic).
* `code/prep_aq_severity.R` - modified to add `aq_transformed` alongside the
  existing `aq_severity` factor.
* `code/prep_stai_trait_severity.R` - modified to add `stai_trait_transformed`
  alongside the existing `stai_trait_severity` factor.
* `code/prep_stai_state_severity.R` - modified to add `stai_state_transformed`
  alongside the existing `stai_state_severity` factor.

All four new transformed plots use the same ADHD = #0072B2 / TD = #D55E00
color pair, jitter/pointrange/theme/ggsave conventions, and dashed-reference-
line style as `plot_bdi_stripplot_transformed.R` (Section 5).

**Untouched (out of scope for this addition):** `plot_bdi_stripplot_transformed.R`,
`prep_bdi_severity.R`, all four `plot_*_stripplot_raw.R` files, all four
`summarize_*_severity.R` files, `plot_selfreport_dothistograms*.R`, and their
outputs.

# Analysis Notebook: Cross-Analysis Ratio Comparison (with-ADHD / without-ADHD)

**Type:** Cross-analysis comparison figure - not a model fit. Reads already-computed
posterior draws from nine sibling `analysis/` folders; fits nothing itself.
**Date Created:** 2026-08-28
**Redesigned (overlay):** 2026-09-01
**Refined (Y-axis + ICAR annotation removed):** 2026-09-02
**Refined (Y-axis de-emphasized as secondary scale):** 2026-09-03
**Fixed (stray legend numbers - root cause was ggdist, not our aes mapping):** 2026-09-03

## 1. Hypotheses
* Not a hypothesis-testing analysis. Produces a single figure comparing the posterior
  "with ADHD mean / without ADHD mean" ratio across all nine already-fit regression
  analyses, so the size and certainty of the ADHD-group effect can be read off a shared
  axis across measures.
* **Redesigned from a stacked ridgeline (one row per measure) into a single overlay**:
  every distribution now sits at the same y = 0 baseline, distinguished only by colour
  and transparency, so each measure's x-position - the actual result being compared - is
  directly comparable rather than separated by row. The underlying draws, medians, and
  credible intervals are unchanged from the ridgeline version; only the layering/display
  changed, per the user's explicit request.

## 2. Variables
* **Outcome:** `ratio` - each sibling's posterior draws of (with-ADHD group mean /
  without-ADHD group mean), read from that sibling's `artifacts/posterior_draws.rds$ratio`.
* **Grouping variable / legend:** `measure` - the 9 source instruments, in the exact order
  and colour the user specified (ICAR first, black; the other 8 each a distinct
  colorblind-safe Okabe-Ito colour):

  | Measure label | Source folder | Colour |
  |---|---|---|
  | ICAR | `analysis/icar_regression_analysis/` | black (`#000000`) |
  | WURS | `analysis/wurs_regression_analysis/` | `#332288` |
  | ASRS | `analysis/asrs_regression_analysis/` | `#117733` |
  | BDI | `analysis/bdi_regression_analysis/` | `#44AA99` |
  | PQ-B | `analysis/pqb_regression_analysis/` | `#88CCEE` |
  | STAI-Trait | `analysis/stai_trait_regression_analysis/` | `#DDCC77` |
  | OCI-R | `analysis/ocir_regression_analysis/` | `#CC6677` |
  | STAI-State | `analysis/stai_state_regression_analysis/` | `#AA4499` |
  | AQ | `analysis/aq_regression_analysis/` | `#882255` |

* **Excluded:** PATAS was originally planned as a 10th measure, but its analysis folder
  (`analysis/patas_regression_analysis/`) has since been deleted from disk (confirmed
  deliberate by the user), so it is not read and does not appear in the comparison.

## 3. Note on ICAR
ICAR's ratio posterior has pd (probability of direction) = 73.58% - weak, inconclusive
evidence, versus pd = 100% for every other measure here. ICAR is also a cognitive-ability
score (higher = better), unlike the other eight symptom-severity scores. In the overlay
redesign it gets identical treatment to the other 8 measures (same alpha, same layer
type) except its colour (black, per the user's request). The `pd` text annotation from
the ridgeline version was removed at the user's request (2026-09-02) - it was a leftover
from the stacked-row layout and no longer belonged on the combined overlay figure. The
underlying `pd`/median computation for ICAR was removed from `prep_ratio_plot_layout.R`
along with it, since nothing else in this figure uses it.

## 4. Legend
* A small solid colored dot per measure (not a shaded density-swatch key), built from a
  dedicated invisible legend-only layer so the automatic ggplot legend doesn't merge the
  density fill/outline with the interval-segment glyphs into a cluttered key.

## 5. Axis
* **X-axis:** shared window across all 9 measures - central 98% mass of the pooled draws
  (with modest padding), always keeping x = 1 (the ratio's null value) visible with a
  margin. Replaces the ridgeline's ~20%-of-full-range padding, now computed once jointly
  rather than needing the wider ridgeline layout compression.
* **Y-axis (added 2026-09-02):** each measure's density curve is computed directly with
  `stats::density()` rather than `ggdist::stat_slab`'s internal thickness aesthetic, which
  by default normalizes each group's peak height independently - that would have hidden
  real information (a narrower posterior legitimately has a taller peak) and was producing
  a stray, incorrectly-positioned numeric axis under the legend. Plotting the raw density
  values directly gives one shared, un-rescaled y-axis ("Posterior density") on the left,
  with a small number of clean `pretty()`-generated tick breaks sized to the tallest curve
  actually present across all 9 measures.
* **Visual hierarchy (2026-09-03):** the y-axis is mathematically correct and unaltered,
  but deliberately styled smaller/lighter/thinner (`grey50`-`grey65`, small text) than the
  x-axis (`grey20`-`grey30`, larger text), so it reads as a secondary reference scale
  rather than implying that a taller peak means a "larger" or "more important" Mean Ratio.
  The x-axis - the actual variable of interest - and its x = 1 dashed reference line
  remain the figure's primary visual anchor.

## 6. Note on a fixed rendering bug
A stray, incorrectly-positioned small guide box ("-0.900" to "-0.800", 0.025 apart, with
its own micro-title) kept appearing under the legend across three rounds of fixes, each
confirmed against a user screenshot.
* Round 1 hypothesis (wrong): `ggdist::stat_slab`'s internal per-group normalization -
  fixed by switching to `stats::density()` for the slab layer, which was a legitimate
  improvement (see §5) but did not remove the stray box.
* Round 2 hypothesis (wrong): `linewidth` mapped as a *continuous* aesthetic via
  `aes(linewidth = after_stat(.width))` on `ggdist::stat_pointinterval` (needed with 9
  groups, since a fixed `linewidth = c(2, 1)` vector recycles incorrectly against 9
  measures x 2 CI widths) - `.width`'s range, `c(0.80, 0.90)`, matched the stray numbers
  exactly, but passing `linewidth` as a fixed parameter instead did not remove the box.
* Round 3, confirmed fix: `ggdist`'s point-interval geoms scale linewidth by interval
  width **internally**, as a built-in feature independent of whatever `aes()`/parameter
  values are supplied from the outside - so no external `guide = "none"` or `guides(...)`
  call could reliably suppress it. Fixed by dropping `ggdist::stat_pointinterval` (and the
  `ggdist` library entirely - no longer used anywhere in this folder) and drawing the
  point + both credible intervals with plain `geom_point()`/`geom_segment()` instead,
  using the exact same equal-tailed quantile values ggdist would have computed. No ggdist
  geom remains in the plot, so no such internal mapping can exist to leak a guide.
  Underlying medians and credible interval values are numerically identical to before;
  only the rendering mechanism changed.

## 7. Findings / Summary
* (Leave this section blank until the figure is reviewed.)

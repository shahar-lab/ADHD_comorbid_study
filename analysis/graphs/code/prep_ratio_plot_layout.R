#### ORDER RATIO MEASURES AND COMPUTE PLOT LAYOUT ####
# reads: artifacts/ratio_draws_combined.rds · writes: artifacts/ratio_plot_layout.rds

ratio_draws_combined <- readRDS(file.path(artifacts_dir, "ratio_draws_combined.rds"))

# Legend order and colour mapping specified directly by the user: ICAR first
# (black), then the other 8 measures in this fixed order, each a distinct
# colorblind-safe colour (Okabe-Ito, matching the palette already used by the
# previous ridgeline version of this figure). This replaces the ridgeline's
# fct_reorder()-by-median row ordering, which no longer applies once every
# distribution shares one y = 0 baseline instead of being stacked into rows.
measure_order   <- c("ICAR", "WURS", "ASRS", "BDI", "PQ-B", "STAI-Trait", "OCI-R", "STAI-State", "AQ")
okabe_ito       <- c("#332288", "#117733", "#44AA99", "#88CCEE", "#DDCC77", "#CC6677", "#AA4499", "#882255")
measure_colours <- setNames(c("#000000", okabe_ito), measure_order)

ratio_draws_combined <- ratio_draws_combined |>
  mutate(measure = factor(measure, levels = measure_order))

# Ratio's null value is 1, not 0 (non-effect posterior). Shared x-axis window
# across all 9 measures: central 98% mass of the pooled draws (with modest
# padding), always keeping x = 1 visible with a margin - replaces the
# ridgeline's ~20%-of-full-range padding, since all 9 distributions now share
# one axis and a tighter window keeps them legible/comparable rather than
# stretched to fit the widest tail.
# NOTE: named x1_margin, not "margin" - build_ratio_plot.R (sourced after
# this script in the same main.R session) calls ggplot2::margin() for
# plot.margin, and a local `margin <- ...` here would shadow that function.
q_lo       <- quantile(ratio_draws_combined$ratio, 0.01)
q_hi       <- quantile(ratio_draws_combined$ratio, 0.99)
pad        <- 0.10 * (q_hi - q_lo)
x1_margin  <- 0.15
xlim_ratio <- c(min(q_lo - pad, 1 - x1_margin), max(q_hi + pad, 1 + x1_margin))

ratio_plot_layout <- list(df = ratio_draws_combined, xlim_ratio = xlim_ratio,
                           measure_colours = measure_colours)

saveRDS(ratio_plot_layout, file.path(artifacts_dir, "ratio_plot_layout.rds"))

#### BUILD OVERLAID COMPARISON OF RATIO POSTERIORS ACROSS MEASURES ####
# reads: artifacts/ratio_plot_layout.rds · writes: artifacts/ratio_comparison_plot.rds

ratio_plot_layout <- readRDS(file.path(artifacts_dir, "ratio_plot_layout.rds"))
df              <- ratio_plot_layout$df
xlim_ratio      <- ratio_plot_layout$xlim_ratio
measure_colours <- ratio_plot_layout$measure_colours

# Median + both credible intervals computed directly with quantile() (equal-
# tailed, matching ggdist's default median_qi() exactly - same numbers, no
# ggdist involved in the computation) rather than via
# ggdist::stat_pointinterval(). ggdist's point-interval geoms automatically
# scale linewidth by interval width internally as a built-in feature, and
# that turned out to be the actual, persistent source of the stray
# "-0.900...-0.800" numbers under the legend (confirmed against a user
# screenshot: still present after linewidth was passed as a fixed parameter,
# and after guides()/scale-level "none" suppression) - not something fixable
# from the outside via aes()/guide arguments. Drawing the point + both
# intervals with plain geom_point()/geom_segment() instead avoids ggdist's
# interval-rendering machinery entirely, so no such internal mapping can
# exist to leak a guide.
interval_df <- df |>
  group_by(measure) |>
  summarise(
    med   = median(ratio),
    lo_80 = quantile(ratio, 0.10), hi_80 = quantile(ratio, 0.90),
    lo_90 = quantile(ratio, 0.05), hi_90 = quantile(ratio, 0.95),
    .groups = "drop"
  )

# Each measure's density curve is computed directly with stats::density()
# (rather than relying on ggdist::stat_slab's internal "thickness" aesthetic,
# which by default normalizes each group's own peak height independently) so
# the y-axis can show one shared, un-rescaled density scale across all 9
# distributions - a narrower posterior legitimately gets a taller peak than a
# wider one, and that difference is real information, not something to
# normalize away. Each curve keeps its own natural support (R's default
# density() range), so nothing is clipped except by coord_cartesian's visual
# window below.
density_df <- df |>
  group_by(measure) |>
  group_modify(~ {
    d <- density(.x$ratio, n = 512)
    tibble(x = d$x, y = d$y)
  }) |>
  ungroup()

y_max    <- max(density_df$y) * 1.08
y_breaks <- pretty(c(0, y_max), n = 4)
y_breaks <- y_breaks[y_breaks >= 0 & y_breaks <= y_max]

# Redesigned from a stacked ridgeline (one row per measure, y = measure) into
# a single overlay: every distribution sits at the same baseline, distinguished
# only by colour and transparency, so the x-position of each distribution -
# the actual result being compared - is directly comparable across measures
# rather than separated by row. The underlying draws, medians, and credible
# intervals are unchanged; only the layering/display changed. The stray ICAR
# pd annotation and the previous ridgeline's ICAR-specific styling are removed
# - all 9 measures now get identical treatment except colour.
p_ratio_comparison <- ggplot() +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey40", linewidth = 0.7) +
  geom_area(data = density_df, aes(x = x, y = y, fill = measure, colour = measure),
            alpha = 0.35, position = "identity", linewidth = 0.3, show.legend = FALSE) +
  # Point + both credible intervals, drawn with plain ggplot2 geoms (see
  # interval_df above for why ggdist::stat_pointinterval was dropped). Wider
  # 90% interval drawn thinner and first/underneath, narrower 80% interval
  # thicker and on top - reproducing the same thick-inner/thin-outer visual
  # convention used throughout this project's other posterior plots, without
  # any ggdist geom involved.
  geom_segment(data = interval_df,
               aes(x = lo_90, xend = hi_90, y = 0, yend = 0, colour = measure),
               linewidth = 0.7, show.legend = FALSE) +
  geom_segment(data = interval_df,
               aes(x = lo_80, xend = hi_80, y = 0, yend = 0, colour = measure),
               linewidth = 1.6, show.legend = FALSE) +
  geom_point(data = interval_df, aes(x = med, y = 0, colour = measure),
             size = 2.2, show.legend = FALSE) +
  scale_fill_manual(values = measure_colours, guide = "none") +
  scale_colour_manual(values = measure_colours) +
  # Dedicated invisible layer purely to drive a clean, single-glyph legend (a
  # small solid dot per measure) rather than the cluttered merged key that
  # combining the density fill/outline with the interval segments would
  # otherwise produce.
  geom_point(data = interval_df, aes(x = med, y = 0, colour = measure),
             size = 0, alpha = 0, inherit.aes = FALSE, show.legend = TRUE) +
  guides(colour = guide_legend(title = NULL,
                                override.aes = list(size = 3.5, shape = 16, alpha = 1)),
         fill = "none") +
  scale_y_continuous(breaks = y_breaks, expand = expansion(mult = c(0, 0.02))) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid    = element_blank(),
    # Y-axis kept simple and mathematically correct (real density values,
    # real tick marks) but deliberately de-emphasized - smaller, lighter,
    # thinner - so it reads as a secondary reference scale rather than
    # competing with the x-axis (the Mean Ratio, the actual variable of
    # interest) for visual weight.
    axis.title.y  = element_text(size = 9, angle = 90, colour = "grey50"),
    axis.text.y   = element_text(size = 7.5, colour = "grey55"),
    axis.ticks.y  = element_line(colour = "grey65", linewidth = 0.3),
    axis.line.y   = element_line(colour = "grey65", linewidth = 0.3),
    # X-axis kept visually prominent - it carries the Mean Ratio, the
    # figure's primary variable, and the x = 1 dashed reference line.
    axis.title.x  = element_text(size = 12, colour = "grey20"),
    axis.text.x   = element_text(size = 10, colour = "grey20"),
    axis.ticks.x  = element_line(colour = "grey30"),
    axis.line.x   = element_line(colour = "grey30", linewidth = 0.6),
    legend.title  = element_blank(),
    plot.margin   = margin(t = 3, r = 6, b = 3, l = 3, unit = "pt")
  ) +
  labs(x = "with ADHD mean / without ADHD mean", y = "Posterior density") +
  coord_cartesian(xlim = xlim_ratio, ylim = c(0, y_max), clip = "on")

saveRDS(p_ratio_comparison, file.path(artifacts_dir, "ratio_comparison_plot.rds"))

#### PLOT SUB-PANEL C: POSTERIOR RATIO (ADHD MEAN / TD MEAN) ####
# reads: artifacts/posterior_draws.rds · writes: artifacts/panel_c.rds

posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))
draws_ratio <- posterior_draws$ratio

ratio_df  <- tibble(theta = draws_ratio)
med_ratio <- median(draws_ratio)
# pd computed relative to the ratio's null value of 1, not 0 - given value
# per the specification/precedent, not a Writer assumption.
# pd_ratio = probability mass on the majority side of 1.
pd_ratio  <- max(mean(draws_ratio > 1), mean(draws_ratio < 1)) * 100

# Ratio's null value is 1, not 0: dashed reference line goes at x = 1.
# Per-plot window: centered on the posterior median with a baseline 2-unit
# span for cross-plot comparability, widened only as needed to cover the
# distribution's central 98% mass (with modest padding) without clipping real
# mass, and always keeping x = 1 visible with a minimum margin from either edge.
q_lo       <- quantile(draws_ratio, 0.01)
q_hi       <- quantile(draws_ratio, 0.99)
pad        <- 0.10 * (q_hi - q_lo)
half_width <- 1
margin     <- 0.15
xlim_ratio <- c(min(med_ratio - half_width, q_lo - pad, 1 - margin),
                max(med_ratio + half_width, q_hi + pad, 1 + margin))

# ASSUMED[unverified pending execution]: same fixed-y annotation anchor
# (y = 1.28) and hjust convention as Panel B, following the established
# aq_regression_analysis/bdi_regression_analysis precedent where the median
# sat near the left edge of the padded (non-symmetric) ratio axis.
p_panel_c <- ggplot(ratio_df, aes(x = theta, y = 0)) +
  stat_slab(fill = "gray80") +
  stat_pointinterval(.width = c(0.80, 0.90), point_size = 3, linewidth = c(2, 1)) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey40", linewidth = 0.7) +
  geom_vline(xintercept = med_ratio, linetype = "dashed", colour = "grey65", linewidth = 0.4) +
  annotate("text", x = med_ratio, y = 1.28,
           label = sprintf("[median = %.2f, pd = %.2f%%]", med_ratio, pd_ratio),
           hjust = -0.05, vjust = 1, size = 3.2, colour = "grey40") +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid   = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    axis.line.y  = element_blank(),
    axis.line.x  = element_line(colour = "grey30")
  ) +
  labs(x = "with ADHD mean / without ADHD mean") +
  coord_cartesian(xlim = xlim_ratio, ylim = c(0, 1.3), clip = "on")

saveRDS(p_panel_c, file.path(artifacts_dir, "panel_c.rds"))

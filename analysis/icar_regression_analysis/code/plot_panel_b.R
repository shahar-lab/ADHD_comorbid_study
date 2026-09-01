#### PLOT PANEL B: EFFECT POSTERIOR (ADHD - TD) ####
# reads: artifacts/posterior_draws.rds · writes: artifacts/panel_b.rds

posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))
draws_diff <- posterior_draws$diff

diff_df  <- tibble(theta = draws_diff)
med_diff <- median(draws_diff)
pd_diff  <- max(mean(draws_diff > 0), mean(draws_diff < 0)) * 100

# Diff's null value is 0, not 1: dashed reference line goes at x = 0.
# Per-plot window: sized to the distribution's own central 98% mass (with
# modest padding) rather than forced symmetric around 0 (which wastes space
# when the whole distribution sits on one side), while always keeping x = 0
# visible with a margin proportional to the window's own span (units are raw
# questionnaire points and differ by measure, so a relative margin is used
# instead of a fixed absolute one).
q_lo        <- quantile(draws_diff, 0.01)
q_hi        <- quantile(draws_diff, 0.99)
pad         <- 0.10 * (q_hi - q_lo)
zero_margin <- 0.15 * ((q_hi + pad) - (q_lo - pad))
xlim_diff   <- c(min(q_lo - pad, -zero_margin), max(q_hi + pad, zero_margin))

p_panel_b <- ggplot(diff_df, aes(x = theta, y = 0)) +
  stat_slab(fill = "gray80") +
  stat_pointinterval(.width = c(0.80, 0.90), point_size = 3, linewidth = c(2, 1)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40", linewidth = 0.7) +
  geom_vline(xintercept = med_diff, linetype = "dashed", colour = "grey65", linewidth = 0.4) +
  annotate("text", x = med_diff, y = 1.28,
           label = sprintf("[median = %.2f, pd = %.2f%%]", med_diff, pd_diff),
           hjust = 1.05, vjust = 1, size = 3.2, colour = "grey40") +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid   = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    axis.line.y  = element_blank(),
    axis.line.x  = element_line(colour = "grey30")
  ) +
  labs(x = "with ADHD - without ADHD (ICAR points)") +
  coord_cartesian(xlim = xlim_diff, ylim = c(0, 1.3), clip = "on")

saveRDS(p_panel_b, file.path(artifacts_dir, "panel_b.rds"))

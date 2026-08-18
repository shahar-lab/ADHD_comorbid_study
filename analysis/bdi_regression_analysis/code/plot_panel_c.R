#### PLOT SUB-PANEL C: POSTERIOR RATIO (ADHD MEAN / TD MEAN) ####
# reads: artifacts/posterior_draws.rds · writes: artifacts/panel_c.rds

posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))
draws_ratio <- posterior_draws$ratio

ratio_df  <- tibble(theta = draws_ratio)
med_ratio <- median(draws_ratio)
# ASSUMED[pd adapted to the ratio's null value of 1, rather than 0]:
# pd_ratio = probability mass on the majority side of 1.
pd_ratio  <- max(mean(draws_ratio > 1), mean(draws_ratio < 1)) * 100

# Ratio's null value is 1, not 0: dashed reference line goes at x = 1, and the
# axis is padded ~20% around the posterior range rather than forced symmetric
# around it (non-effect-posterior axis rule - a deliberate, approved deviation
# from the strict effect/non-effect binary, since a ratio fits neither cleanly).
r    <- range(draws_ratio)
span <- diff(r)
xlim_ratio <- c(r[1] - 0.20 * span, r[2] + 0.20 * span)

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
  labs(x = "ADHD mean / TD mean") +
  coord_cartesian(xlim = xlim_ratio, ylim = c(0, 1.3), clip = "on")

saveRDS(p_panel_c, file.path(artifacts_dir, "panel_c.rds"))

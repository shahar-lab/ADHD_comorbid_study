#### PLOT PANEL B: EFFECT POSTERIOR (ADHD - TD) ####
# reads: artifacts/posterior_draws.rds · writes: artifacts/panel_b.rds

posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))
draws_diff <- posterior_draws$diff

diff_df  <- tibble(theta = draws_diff)
med_diff <- median(draws_diff)
pd_diff  <- max(mean(draws_diff > 0), mean(draws_diff < 0)) * 100
max_abs  <- max(abs(range(draws_diff)))

# ASSUMED[unverified pending execution]: this model has never actually been
# fit in this folder (artifacts/ and output/ contain only .gitkeep), so
# med_diff/max_abs are not yet known and this alignment has not been checked
# against real fitted values. hjust = 1.05 (right-aligned) is used as the
# safer default because aq_regression_analysis's sibling Panel B ultimately
# needed right-alignment (median close to the max_abs boundary), and bdi's
# effect posterior — a positive group effect, with max_abs defined as the
# most extreme posterior draw — is likely to have similar geometry. The
# orchestrator should re-check this against the actual fitted med_diff/max_abs
# once the pipeline is run, and switch to hjust = -0.05 if there turns out to
# be room on the left instead.
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
  labs(x = "ADHD - TD (BDI points)") +
  coord_cartesian(xlim = c(-max_abs, max_abs), ylim = c(0, 1.3), clip = "on")

saveRDS(p_panel_b, file.path(artifacts_dir, "panel_b.rds"))

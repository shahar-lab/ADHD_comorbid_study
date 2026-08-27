#### PLOT PANEL D: POSTERIOR PROPORTION ABOVE CLINICAL CUTOFF ####
# reads: artifacts/model_fit.rds, artifacts/posterior_draws.rds · writes: artifacts/panel_d.rds

model_fit       <- readRDS(file.path(artifacts_dir, "model_fit.rds"))
posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))

group_colors <- c(ADHD = "#0072B2", TD = "#D55E00")
cutoff_raw   <- 21

# Residual SD draws - single population-level sigma in this model (no
# distributional formula for sigma), paired index-for-index with
# posterior_draws$td / $adhd since both come from model_fit's own draws.
sigma_draws <- as_draws_df(model_fit)$sigma

# Model-implied probability that a random individual in each group scores
# above the clinical cutoff, assuming Gaussian(group mean draw, sigma draw).
prop_above_td   <- 1 - pnorm(cutoff_raw, mean = posterior_draws$td,   sd = sigma_draws)
prop_above_adhd <- 1 - pnorm(cutoff_raw, mean = posterior_draws$adhd, sd = sigma_draws)

prop_df <- bind_rows(
  tibble(theta = prop_above_td,   group_declared = "TD"),
  tibble(theta = prop_above_adhd, group_declared = "ADHD")
)

p_panel_d <- ggplot(prop_df, aes(x = theta, y = 0, fill = group_declared, colour = group_declared)) +
  stat_slab(alpha = 0.50) +
  stat_pointinterval(
    aes(linewidth = after_stat(.width)),
    .width     = c(0.80, 0.90),
    point_size = 3
  ) +
  scale_linewidth_continuous(range = c(2, 1), guide = "none") +
  scale_fill_manual(values = group_colors, labels = c(TD = "without ADHD", ADHD = "with ADHD"),
                     guide = guide_legend(override.aes = list(alpha = 0.7))) +
  scale_colour_manual(values = group_colors, guide = "none") +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid           = element_blank(),
    axis.title.y         = element_blank(),
    axis.text.y          = element_blank(),
    axis.ticks.y         = element_blank(),
    axis.line.y          = element_blank(),
    axis.line.x          = element_line(colour = "grey30"),
    legend.position      = c(1, 0.95),
    legend.justification = c("right", "top"),
    legend.background    = element_blank(),
    legend.key           = element_blank()
  ) +
  # ASSUMED[exact axis wording not specified]: "Proportion of group above
  # clinical cutoff", following the spec's suggested wording verbatim.
  labs(x = "Proportion of group above clinical cutoff", fill = NULL) +
  # Proportion is bounded in [0, 1] by construction, so the axis spans the
  # full domain rather than a padded window around the draws (unlike Panel
  # C's ratio, which has no natural bound).
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1.3))

saveRDS(p_panel_d, file.path(artifacts_dir, "panel_d.rds"))

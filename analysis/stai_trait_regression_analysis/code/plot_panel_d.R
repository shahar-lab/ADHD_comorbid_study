#### PLOT PANEL D: POSTERIOR PROPORTION ABOVE CLINICAL CUTOFF ####
# reads: artifacts/model_fit.rds, artifacts/posterior_draws.rds · writes: artifacts/panel_d.rds

model_fit       <- readRDS(file.path(artifacts_dir, "model_fit.rds"))
posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))

group_colors <- c(ADHD = "#0072B2", TD = "#D55E00")
group_labels <- c(TD = "without ADHD", ADHD = "with ADHD")
cutoff_raw   <- 44

# Residual SD draws, in the same posterior-draw order as posterior_draws$td /
# $adhd (both read off the same post-warmup MCMC draws via as_draws_df's /
# posterior_epred's shared default draw order), so each sigma draw is paired
# with the group-mean draw from the same posterior sample.
sigma_draws <- as_draws_df(model_fit)$sigma

# Model-implied probability that a random individual in each group scores
# above cutoff_raw, assuming the outcome is Gaussian around that draw's
# group mean with that draw's residual SD.
prop_above_td   <- 1 - pnorm(cutoff_raw, mean = posterior_draws$td,   sd = sigma_draws)
prop_above_adhd <- 1 - pnorm(cutoff_raw, mean = posterior_draws$adhd, sd = sigma_draws)

prop_df <- bind_rows(
  tibble(theta = prop_above_td,   group_declared = "TD"),
  tibble(theta = prop_above_adhd, group_declared = "ADHD")
) |>
  mutate(group_declared = factor(group_declared, levels = c("TD", "ADHD")))

# Non-effect posterior (a bounded proportion, not centred on zero): pad ~20%
# around the observed posterior range rather than forcing zero onto the axis,
# clamped to the [0, 1] proportion range.
r    <- range(prop_df$theta)
span <- diff(r)
xlim_prop <- c(max(0, r[1] - 0.20 * span), min(1, r[2] + 0.20 * span))

p_panel_d <- ggplot(prop_df, aes(x = theta, y = 0, fill = group_declared, colour = group_declared)) +
  stat_slab(alpha = 0.50) +
  stat_pointinterval(
    aes(linewidth = after_stat(.width)),
    .width     = c(0.80, 0.90),
    point_size = 3
  ) +
  scale_linewidth_continuous(range = c(2, 1), guide = "none") +
  scale_fill_manual(values = group_colors, labels = group_labels,
                     guide = guide_legend(override.aes = list(alpha = 0.7))) +
  scale_colour_manual(values = group_colors, guide = "none") +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid            = element_blank(),
    axis.title.y          = element_blank(),
    axis.text.y           = element_blank(),
    axis.ticks.y          = element_blank(),
    axis.line.y           = element_blank(),
    axis.line.x           = element_line(colour = "grey30"),
    legend.position        = c(1, 0.95),
    legend.justification   = c("right", "top"),
    legend.background      = element_blank(),
    legend.key             = element_blank()
  ) +
  labs(x = "Proportion of group above clinical cutoff", fill = NULL) +
  coord_cartesian(xlim = xlim_prop, ylim = c(0, 1.3))

saveRDS(p_panel_d, file.path(artifacts_dir, "panel_d.rds"))

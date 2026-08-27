#### PLOT PANEL D: POSTERIOR PROPORTION ABOVE CLINICAL CUTOFF ####
# reads: artifacts/model_fit.rds, artifacts/posterior_draws.rds · writes: artifacts/panel_d.rds

model_fit       <- readRDS(file.path(artifacts_dir, "model_fit.rds"))
posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))

group_colors <- c(ADHD = "#0072B2", TD = "#D55E00")
group_labels <- c(TD = "without ADHD", ADHD = "with ADHD")
cutoff_raw   <- 14

# Residual SD draws, same posterior-draw order as posterior_draws$td/$adhd
# (both drawn from model_fit's post-warmup draws in their original order),
# so pairing sigma_draws[i] with the group mean draw at index i is valid.
sigma_draws <- as_draws_df(model_fit)$sigma

# Model-implied probability a random individual in the group scores at/above
# the clinical cutoff, assuming a Gaussian outcome around each draw's group mean.
prop_above_td   <- 1 - pnorm(cutoff_raw, mean = posterior_draws$td, sd = sigma_draws)
prop_above_adhd <- 1 - pnorm(cutoff_raw, mean = posterior_draws$adhd, sd = sigma_draws)

prop_df <- bind_rows(
  tibble(prop_above = prop_above_td, group_declared = "TD"),
  tibble(prop_above = prop_above_adhd, group_declared = "ADHD")
) |>
  mutate(group_declared = factor(group_declared, levels = c("TD", "ADHD")))

# Non-effect posterior on a bounded [0, 1] proportion scale: pad the observed
# range by 20% per plot-posterior/instructions.md, then clamp to [0, 1]
# (SPECIFICATION §1) since values outside that range are not meaningful for
# a proportion.
r    <- range(prop_df$prop_above)
span <- diff(r)
xlim_prop <- c(max(0, r[1] - 0.20 * span), min(1, r[2] + 0.20 * span))

p_panel_d <- ggplot(prop_df, aes(x = prop_above, y = 0, fill = group_declared, colour = group_declared)) +
  stat_slab(alpha = 0.50) +
  stat_pointinterval(
    aes(linewidth = after_stat(.width)),
    .width     = c(0.80, 0.90),
    point_size = 3
  ) +
  scale_linewidth_continuous(range = c(2, 1), guide = "none") +
  # ASSUMED[no reference-line rule given for a bounded proportion]: no dashed
  # reference line is drawn. Unlike a difference (null = 0) or plot_panel_c.R's
  # ratio (null = 1), a proportion-above-cutoff has no privileged null value —
  # there is no "no effect" proportion to mark, so a dashed line at 0 (or
  # anywhere else) would not represent a meaningful reference point here.
  scale_fill_manual(values = group_colors, labels = group_labels,
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
    legend.position       = c(1, 0.95),
    legend.justification  = c("right", "top"),
    legend.background     = element_blank(),
    legend.key            = element_blank()
  ) +
  labs(x = "Proportion of group above clinical cutoff (BDI ≥ 14)", fill = NULL) +
  coord_cartesian(xlim = xlim_prop, ylim = c(0, 1.3), clip = "on")

saveRDS(p_panel_d, file.path(artifacts_dir, "panel_d.rds"))

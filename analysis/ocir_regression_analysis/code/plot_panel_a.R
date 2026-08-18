#### PLOT PANEL A: EMPIRICAL DATA + POSTERIOR GROUP PREDICTIONS ####
# reads: artifacts/df_regression.rds, artifacts/posterior_draws.rds · writes: artifacts/panel_a.rds

df              <- readRDS(file.path(artifacts_dir, "df_regression.rds"))
posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))

group_colors <- c(ADHD = "#0072B2", TD = "#D55E00")
cutoff_raw   <- 21
# Colorblind-safe, low-saturation pair for the cutoff bands (grey + sand),
# reused from aq_regression_analysis/bdi_regression_analysis's Panel A
# precedent, deliberately outside the blue/vermillion family used for group
# colors above, per COLOR_STANDARD.md.
band_colors  <- c(below = "#BBBBBB", at_or_above = "#DDCC77")

# Posterior median + 90% CI per group, for the model-prediction layer
pred_summary <- tibble(
  group_declared = factor(c("TD", "ADHD"), levels = c("TD", "ADHD")),
  median_val = c(median(posterior_draws$td), median(posterior_draws$adhd)),
  lower90    = c(quantile(posterior_draws$td, 0.05), quantile(posterior_draws$adhd, 0.05)),
  upper90    = c(quantile(posterior_draws$td, 0.95), quantile(posterior_draws$adhd, 0.95))
) |>
  mutate(x_pos = as.numeric(group_declared) + 0.3)

print(pred_summary)

p_panel_a <- ggplot(df, aes(x = group_declared, y = ocir)) +
  # Shaded cutoff bands, drawn first so all data/prediction layers sit on top
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = cutoff_raw,
           fill = band_colors["below"], alpha = 0.25) +
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = cutoff_raw, ymax = 72,
           fill = band_colors["at_or_above"], alpha = 0.25) +
  geom_hline(yintercept = cutoff_raw, linetype = "dashed", color = "grey40") +
  annotate("text", x = Inf, y = cutoff_raw, label = "21",
           hjust = 1.1, vjust = -0.4, size = 3.2, color = "grey30") +
  geom_jitter(aes(color = group_declared), width = 0.15, height = 0, alpha = 0.6, size = 2) +
  # Posterior group-mean predictions (median + 90% CI), offset and shaped
  # distinctly from the raw jittered points above. Explicit segment (whisker)
  # plus a separate point layer (median), both keyed off x_pos, rather than
  # geom_pointrange + position_nudge (geom_pointrange's default marker size
  # swallows narrow CI whiskers - bug already found and fixed in
  # aq_regression_analysis).
  geom_segment(data = pred_summary,
               aes(x = x_pos, xend = x_pos, y = lower90, yend = upper90),
               inherit.aes = FALSE, linewidth = 1.2, color = "black") +
  # ASSUMED[no exact point size given]: size = 2, reused from
  # aq_regression_analysis/bdi_regression_analysis's precedent, so the point
  # does not swallow the whisker.
  geom_point(data = pred_summary,
             aes(x = x_pos, y = median_val),
             inherit.aes = FALSE, shape = 15, size = 2, color = "black") +
  scale_color_manual(values = group_colors, name = "Group") +
  scale_y_continuous(limits = c(0, 72)) +
  labs(x = "Group", y = "OCIR score (0-72)") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank(), legend.position = "bottom")

saveRDS(p_panel_a, file.path(artifacts_dir, "panel_a.rds"))

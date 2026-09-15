#### PANEL A: POSTERIOR CLES DISTRIBUTIONS PER MEASURE ####
# reads: artifacts/posterior_cles_draws.rds · writes: artifacts/panel_a.rds

posterior_cles_draws <- readRDS(file.path(artifacts_dir, "posterior_cles_draws.rds"))

measure_levels <- c("AQ", "ASRS", "WURS", "BDI", "OCI-R", "PQ-B", "STAI-State", "STAI-Trait", "ICAR")
measure_labels <- c(aq = "AQ", asrs = "ASRS", wurs = "WURS", bdi = "BDI", ocir = "OCI-R",
                     pqb = "PQ-B", stai_state = "STAI-State", stai_trait = "STAI-Trait", icar = "ICAR")

plot_df <- posterior_cles_draws |>
  mutate(label = factor(measure_labels[outcome], levels = measure_levels))

# Paul Tol muted palette, one color per measure, per COLOR_STANDARD.md.
measure_colors <- c(
  AQ = "#332288", ASRS = "#117733", WURS = "#44AA99", BDI = "#88CCEE", `OCI-R` = "#DDCC77",
  `PQ-B` = "#CC6677", `STAI-State` = "#AA4499", `STAI-Trait` = "#882255", ICAR = "#999933"
)

# ASSUMED[job spec explicitly asks only for the posterior median and a single
# 95% CrI per facet, narrower than the routed posterior-plot doc's default
# nested 80/90% interval]: .width = 0.95 only, per this job's own spec (§9).
facet_summary <- plot_df |>
  group_by(label) |>
  summarise(median_cles = median(CLES), ci_lower = unname(quantile(CLES, 0.025)),
            ci_upper = unname(quantile(CLES, 0.975)), .groups = "drop")

# ASSUMED[CLES is a non-effect, bounded-probability posterior (not centred on
# zero), matching the sibling regression folders' own precedent for bounded
# proportions, e.g. plot_panel_d.R's "proportion above cutoff" panel]: pad ~20%
# around the observed posterior range per the routed doc's non-effect-posterior
# rule, clamped to CLES's natural [0, 1] bound (per spec §10, never widened
# past a valid probability) rather than the fixed xlim used previously.
r         <- range(plot_df$CLES)
span      <- diff(r)
xlim_cles <- c(max(0, r[1] - 0.20 * span), min(1, r[2] + 0.20 * span))

p_panel_a <- ggplot(plot_df, aes(x = CLES, y = 0, fill = label, colour = label)) +
  stat_slab(alpha = 0.60, show.legend = FALSE) +
  stat_pointinterval(.width = 0.95, point_size = 2, linewidth = 1.2, show.legend = FALSE) +
  geom_vline(xintercept = 0.50, linetype = "dashed", colour = "grey40", linewidth = 0.6) +
  geom_vline(data = facet_summary, aes(xintercept = median_cles),
             linetype = "dashed", colour = "grey65", linewidth = 0.4, inherit.aes = FALSE) +
  geom_text(
    data = facet_summary,
    aes(x = 0.5, y = Inf, label = sprintf("%.2f [%.2f-%.2f]", median_cles, ci_lower, ci_upper)),
    inherit.aes = FALSE, hjust = 0.5, vjust = 1.6, size = 2.8, colour = "grey30"
  ) +
  scale_fill_manual(values = measure_colors) +
  scale_colour_manual(values = measure_colors) +
  facet_wrap(~ label, ncol = 3) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid   = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    axis.line.y  = element_blank(),
    axis.line.x  = element_line(colour = "grey30"),
    strip.text   = element_text(face = "bold")
  ) +
  labs(x = "Posterior CLES  [P(ADHD > TD)]") +
  coord_cartesian(xlim = xlim_cles, ylim = c(0, 1.7), clip = "off")

saveRDS(p_panel_a, file.path(artifacts_dir, "panel_a.rds"))

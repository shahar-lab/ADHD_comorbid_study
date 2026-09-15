#### PANEL B: OBSERVED VS. POSTERIOR CLES (FOREST-PLOT LAYOUT) ####
# reads: output/cles_summary.csv · writes: artifacts/panel_b.rds

cles_summary <- read_csv(file.path(output_dir, "cles_summary.csv"), show_col_types = FALSE)

measure_levels <- c("AQ", "ASRS", "WURS", "BDI", "OCI-R", "PQ-B", "STAI-State", "STAI-Trait", "ICAR")

# Reshape to long format so "type" (observed vs. posterior median) maps to a
# proper colour/shape legend, all in the consistent ADHD > TD direction.
plot_long <- bind_rows(
  cles_summary |> transmute(Measure, type = "Posterior median", value = `Posterior Median CLES`,
                             ci_lower = `95% CrI Lower`, ci_upper = `95% CrI Upper`),
  cles_summary |> transmute(Measure, type = "Observed", value = `Observed CLES`,
                             ci_lower = NA_real_, ci_upper = NA_real_)
) |>
  mutate(
    Measure = factor(Measure, levels = rev(measure_levels)),
    type    = factor(type, levels = c("Posterior median", "Observed"))
  )

# 2-color scatter pair per COLOR_STANDARD.md ("Default": blue point, rose line).
type_colors <- c(`Posterior median` = "#4477AA", `Observed` = "#EE6677")
type_shapes <- c(`Posterior median` = 16, `Observed` = 17)

p_panel_b <- ggplot(plot_long, aes(y = Measure, x = value, colour = type, shape = type)) +
  geom_vline(xintercept = 0.50, linetype = "dashed", colour = "grey40", linewidth = 0.6) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0, linewidth = 1, na.rm = TRUE) +
  geom_point(size = 3) +
  scale_colour_manual(values = type_colors) +
  scale_shape_manual(values = type_shapes) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.minor     = element_blank(),
    panel.grid.major.y   = element_blank(),
    axis.title.y         = element_blank(),
    axis.line.x          = element_line(colour = "grey30"),
    legend.position       = c(0.98, 0.02),
    legend.justification = c("right", "bottom"),
    legend.background    = element_blank(),
    legend.key           = element_blank(),
    legend.title          = element_blank()
  ) +
  labs(x = "CLES  [P(ADHD > TD)]") +
  coord_cartesian(xlim = c(0, 1))

saveRDS(p_panel_b, file.path(artifacts_dir, "panel_b.rds"))

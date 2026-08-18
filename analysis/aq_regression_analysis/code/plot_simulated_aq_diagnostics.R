#### PLOT SIMULATED AQ DIAGNOSTICS ####
# reads: artifacts/simulated_aq_from_posterior.csv · writes: output/simulated_aq_diagnostics.pdf, output/simulated_aq_diagnostics.png

df_sim <- read_csv(file.path(artifacts_dir, "simulated_aq_from_posterior.csv"), show_col_types = FALSE)

group_colors <- c(ADHD = "#0072B2", TD = "#D55E00")

# Panel A: histogram + density overlay, by group
p_hist_group <- ggplot(df_sim, aes(x = AQ, fill = group, color = group)) +
  geom_histogram(aes(y = after_stat(density)), position = "identity", alpha = 0.4, bins = 20) +
  geom_density(alpha = 0, linewidth = 1) +
  scale_fill_manual(values = group_colors, name = "Group") +
  scale_color_manual(values = group_colors, name = "Group") +
  labs(title = "AQ Distribution by Group", x = "AQ score", y = "Density") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank(), legend.position = "bottom")

# Panel B: histogram + density overlay, combined across groups
p_hist_overall <- ggplot(df_sim, aes(x = AQ)) +
  geom_histogram(aes(y = after_stat(density)), fill = "grey60", color = "grey30", alpha = 0.6, bins = 20) +
  geom_density(color = "black", linewidth = 1) +
  labs(title = "AQ Distribution: Overall", x = "AQ score", y = "Density") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

# Panels C-D: Q-Q plots against a normal distribution, one per group
p_qq_adhd <- ggplot(df_sim |> filter(group == "ADHD"), aes(sample = AQ)) +
  stat_qq(color = unname(group_colors["ADHD"]), alpha = 0.7, size = 1.8) +
  stat_qq_line(color = "grey30", linetype = "dashed") +
  labs(title = "Q-Q Plot: ADHD", x = "Theoretical Quantiles", y = "Sample Quantiles (AQ)") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

p_qq_td <- ggplot(df_sim |> filter(group == "TD"), aes(sample = AQ)) +
  stat_qq(color = unname(group_colors["TD"]), alpha = 0.7, size = 1.8) +
  stat_qq_line(color = "grey30", linetype = "dashed") +
  labs(title = "Q-Q Plot: TD", x = "Theoretical Quantiles", y = "Sample Quantiles (AQ)") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

# ASSUMED[no layout given]: 2x2 composite (histograms on top, Q-Q plots
# below), tagged per PANEL_TAGGING_STANDARD.md since this is a 4-panel figure.
p_final <- (p_hist_group | p_hist_overall) / (p_qq_adhd | p_qq_td) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(face = "bold", size = 14))

plot_name <- "simulated_aq_diagnostics"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_final, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_final, width = 10, height = 8, dpi = 300, bg = "white")

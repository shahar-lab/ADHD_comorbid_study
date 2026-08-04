#### PLOT BDI STRIP PLOT (TRANSFORMED 0-100 SCALE) ####

# Same ADHD/TD color convention established in plot_selfreport_dothistograms.R
group_colors <- c(ADHD = "#0072B2", TD = "#D55E00")
cutoffs_transformed <- c(13, 19, 28) / 63 * 100

group_stats_transformed <- df_bdi_severity |>
  group_by(group_declared) |>
  summarise(mean_val = mean(bdi_transformed), sd_val = sd(bdi_transformed), .groups = "drop")

p_bdi_transformed <- ggplot(df_bdi_severity, aes(x = group_declared, y = bdi_transformed, color = group_declared)) +
  geom_hline(yintercept = cutoffs_transformed, linetype = "dashed", color = "grey40") +
  annotate("text", x = Inf, y = cutoffs_transformed, label = c("13", "19", "28"),
           hjust = 1.1, vjust = -0.4, size = 3.2, color = "grey30") +
  geom_jitter(width = 0.15, height = 0, alpha = 0.6, size = 2) +
  geom_pointrange(data = group_stats_transformed,
                   aes(x = group_declared, y = mean_val,
                       ymin = mean_val - sd_val, ymax = mean_val + sd_val,
                       color = group_declared),
                   inherit.aes = FALSE, shape = 18, size = 1.1, linewidth = 1.2) +
  scale_color_manual(values = group_colors, name = "Group") +
  scale_y_continuous(limits = c(0, 100)) +
  labs(x = "Group", y = "BDI score (0-100 rescaled)",
       title = "BDI severity by group (transformed scale)") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank(), legend.position = "bottom")

plot_name <- "bdi_stripplot_transformed"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_bdi_transformed, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_bdi_transformed, width = 10, height = 8, dpi = 300, bg = "white")

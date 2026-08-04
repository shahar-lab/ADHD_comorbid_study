#### PLOT BDI STRIP PLOT (RAW 0-63 SCALE) ####

# Same ADHD/TD color convention established in plot_selfreport_dothistograms.R
group_colors <- c(ADHD = "#0072B2", TD = "#D55E00")
cutoffs_raw  <- c(13, 19, 28)

group_stats_raw <- df_bdi_severity |>
  group_by(group_declared) |>
  summarise(mean_val = mean(bdi), sd_val = sd(bdi), .groups = "drop")

p_bdi_raw <- ggplot(df_bdi_severity, aes(x = group_declared, y = bdi, color = group_declared)) +
  geom_hline(yintercept = cutoffs_raw, linetype = "dashed", color = "grey40") +
  annotate("text", x = Inf, y = cutoffs_raw, label = c("13", "19", "28"),
           hjust = 1.1, vjust = -0.4, size = 3.2, color = "grey30") +
  geom_jitter(width = 0.15, height = 0, alpha = 0.6, size = 2) +
  geom_pointrange(data = group_stats_raw,
                   aes(x = group_declared, y = mean_val,
                       ymin = mean_val - sd_val, ymax = mean_val + sd_val,
                       color = group_declared),
                   inherit.aes = FALSE, shape = 18, size = 1.1, linewidth = 1.2) +
  scale_color_manual(values = group_colors, name = "Group") +
  scale_y_continuous(limits = c(0, 63)) +
  labs(x = "Group", y = "BDI score (0-63)",
       title = "BDI severity by group (raw scale)") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank(), legend.position = "bottom")

plot_name <- "bdi_stripplot_raw"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_bdi_raw, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_bdi_raw, width = 10, height = 8, dpi = 300, bg = "white")

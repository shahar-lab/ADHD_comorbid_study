#### PLOT SELF-REPORT DOT HISTOGRAMS ####

# Colorblind-safe blue/red (Okabe-Ito): no prior ADHD/TD color convention
# found elsewhere in the repo, so this mapping is introduced here.
group_colors <- c(ADHD = "#0072B2", TD = "#D55E00")

# BDI panel
df_bdi <- df |> select(group_declared, value = bdi) |> filter(!is.na(value))

p_bdi <- ggplot(df_bdi, aes(x = value, fill = group_declared, color = group_declared)) +
  geom_dotplot(binaxis = "x", stackdir = "up", stackgroups = TRUE, binpositions = "all",
               binwidth = 2, dotsize = 0.7, alpha = 0.85) +
  scale_fill_manual(values = group_colors, name = "Group") +
  scale_color_manual(values = group_colors, name = "Group") +
  scale_y_continuous(NULL, breaks = NULL) +
  labs(x = "BDI score", title = "BDI") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

# AQ panel
df_aq <- df |> select(group_declared, value = aq) |> filter(!is.na(value))

p_aq <- ggplot(df_aq, aes(x = value, fill = group_declared, color = group_declared)) +
  geom_dotplot(binaxis = "x", stackdir = "up", stackgroups = TRUE, binpositions = "all",
               binwidth = 1, dotsize = 0.7, alpha = 0.85) +
  scale_fill_manual(values = group_colors, name = "Group") +
  scale_color_manual(values = group_colors, name = "Group") +
  scale_y_continuous(NULL, breaks = NULL) +
  labs(x = "AQ score", title = "AQ") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

# OCIR panel
df_ocir <- df |> select(group_declared, value = ocir) |> filter(!is.na(value))

p_ocir <- ggplot(df_ocir, aes(x = value, fill = group_declared, color = group_declared)) +
  geom_dotplot(binaxis = "x", stackdir = "up", stackgroups = TRUE, binpositions = "all",
               binwidth = 2, dotsize = 0.7, alpha = 0.85) +
  scale_fill_manual(values = group_colors, name = "Group") +
  scale_color_manual(values = group_colors, name = "Group") +
  scale_y_continuous(NULL, breaks = NULL) +
  labs(x = "OCI-R score", title = "OCIR") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

# Assemble (patchwork, mandatory panel tagging for 3+ panels)
p_final <- (p_bdi | p_aq | p_ocir) +
  plot_layout(guides = "collect") +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(face = "bold", size = 14),
        legend.position = "bottom")

plot_name <- "selfreport_dothistograms"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_final, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_final, width = 10, height = 8, dpi = 300, bg = "white")

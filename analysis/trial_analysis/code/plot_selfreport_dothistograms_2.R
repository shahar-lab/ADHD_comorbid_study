#### PLOT SELF-REPORT DOT HISTOGRAMS 2 (STAI-TRAIT, STAI-STATE, ICAR) ####

# Same ADHD/TD color convention established in plot_selfreport_dothistograms.R
group_colors <- c(ADHD = "#0072B2", TD = "#D55E00")

# STAI-Trait panel
df_stai_trait <- df |> select(group_declared, value = stai_trait) |> filter(!is.na(value))

p_stai_trait <- ggplot(df_stai_trait, aes(x = value, fill = group_declared, color = group_declared)) +
  geom_dotplot(binaxis = "x", stackdir = "up", stackgroups = TRUE, binpositions = "all",
               binwidth = 2, dotsize = 0.7, alpha = 0.85) +
  scale_fill_manual(values = group_colors, name = "Group") +
  scale_color_manual(values = group_colors, name = "Group") +
  scale_y_continuous(NULL, breaks = NULL) +
  labs(x = "STAI-Trait score", title = "STAI-Trait") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

# STAI-State panel
df_stai_state <- df |> select(group_declared, value = stai_state) |> filter(!is.na(value))

p_stai_state <- ggplot(df_stai_state, aes(x = value, fill = group_declared, color = group_declared)) +
  geom_dotplot(binaxis = "x", stackdir = "up", stackgroups = TRUE, binpositions = "all",
               binwidth = 2, dotsize = 0.7, alpha = 0.85) +
  scale_fill_manual(values = group_colors, name = "Group") +
  scale_color_manual(values = group_colors, name = "Group") +
  scale_y_continuous(NULL, breaks = NULL) +
  labs(x = "STAI-State score", title = "STAI-State") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

# ICAR panel
df_icar <- df |> select(group_declared, value = icar) |> filter(!is.na(value))

p_icar <- ggplot(df_icar, aes(x = value, fill = group_declared, color = group_declared)) +
  geom_dotplot(binaxis = "x", stackdir = "up", stackgroups = TRUE, binpositions = "all",
               binwidth = 1, dotsize = 0.7, alpha = 0.85) +
  scale_fill_manual(values = group_colors, name = "Group") +
  scale_color_manual(values = group_colors, name = "Group") +
  scale_y_continuous(NULL, breaks = NULL) +
  labs(x = "ICAR score", title = "ICAR") +
  theme_minimal(base_size = 13) +
  theme(panel.grid = element_blank())

# Assemble (patchwork, mandatory panel tagging for 3+ panels)
p_final <- (p_stai_trait | p_stai_state | p_icar) +
  plot_layout(guides = "collect") +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(face = "bold", size = 14),
        legend.position = "bottom")

plot_name <- "selfreport_dothistograms_2"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_final, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_final, width = 10, height = 8, dpi = 300, bg = "white")

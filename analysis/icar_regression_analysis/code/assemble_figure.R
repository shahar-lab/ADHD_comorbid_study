#### ASSEMBLE COMPOSITE FIGURE ####
# reads: artifacts/panel_a.rds, artifacts/panel_b.rds, artifacts/panel_c.rds · writes: output/regression_results.pdf, output/regression_results.png

p_panel_a <- readRDS(file.path(artifacts_dir, "panel_a.rds"))
p_panel_b <- readRDS(file.path(artifacts_dir, "panel_b.rds"))
p_panel_c <- readRDS(file.path(artifacts_dir, "panel_c.rds"))

# Panel A on the left; Panels B, C stacked top-to-bottom on the right, per
# PANEL_TAGGING_STANDARD.md (patchwork only) and EXPORT_STANDARD.md's
# mandated 10x8 canvas.
p_final <- (p_panel_a | (p_panel_b / p_panel_c)) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(face = "bold", size = 14))

plot_name <- "regression_results"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_final, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_final, width = 10, height = 8, dpi = 300, bg = "white")

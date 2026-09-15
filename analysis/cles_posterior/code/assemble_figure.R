#### ASSEMBLE CLES DIAGNOSTIC FIGURE (PANELS A+B) ####
# reads: artifacts/panel_a.rds, artifacts/panel_b.rds
# writes: output/cles_diagnostics.pdf, output/cles_diagnostics.png

p_panel_a <- readRDS(file.path(artifacts_dir, "panel_a.rds"))
p_panel_b <- readRDS(file.path(artifacts_dir, "panel_b.rds"))

p_final <- (p_panel_a / p_panel_b) +
  plot_layout(heights = c(1.6, 1)) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(face = "bold", size = 14))

plot_name <- "cles_diagnostics"

# EXPORT_STANDARD.md defaults (10x8in): no user request in the approved
# SPECIFICATION authorizes deviating from them, so they are kept as-is.
ggsave(file.path(output_dir, paste0(plot_name, ".pdf")), plot = p_final, width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, paste0(plot_name, ".png")), plot = p_final, width = 10, height = 8, dpi = 300, bg = "white")

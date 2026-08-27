#### ASSEMBLE COMPOSITE FIGURE ####
# reads: artifacts/panel_a.rds, artifacts/panel_b.rds, artifacts/panel_c.rds, artifacts/panel_d.rds
# writes: output/regression_results.pdf, output/regression_results.png

p_panel_a <- readRDS(file.path(artifacts_dir, "panel_a.rds"))
p_panel_b <- readRDS(file.path(artifacts_dir, "panel_b.rds"))
p_panel_c <- readRDS(file.path(artifacts_dir, "panel_c.rds"))
p_panel_d <- readRDS(file.path(artifacts_dir, "panel_d.rds"))

# Panel A on the left; Panels B, C, D stacked top-to-bottom on the right.
# ASSUMED[no exact layout proportions given]: widen the A column relative to
# the stacked B/C/D column (2:1.4) and shrink the stacked panels' text/point
# sizing so all four panels stay legible within the standard 10x8 canvas,
# per EXPORT_STANDARD.md (width/height are modified only on explicit user
# request for "wider"/"smaller", which was never given here).
p_bcd <- (p_panel_b / p_panel_c / p_panel_d) &
  theme(
    axis.title.x = element_text(size = 9),
    axis.text.x  = element_text(size = 8),
    legend.text  = element_text(size = 8),
    legend.title = element_text(size = 8)
  )

p_final <- (p_panel_a | p_bcd) +
  plot_layout(widths = c(2, 1.4)) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(face = "bold", size = 14))

plot_name <- "regression_results"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_final, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_final, width = 10, height = 8, dpi = 300, bg = "white")

#### ASSEMBLE COMPOSITE FIGURE ####
# reads: artifacts/panel_a.rds, artifacts/panel_b.rds, artifacts/panel_c.rds, artifacts/panel_d.rds
# writes: output/regression_results.pdf, output/regression_results.png

p_panel_a <- readRDS(file.path(artifacts_dir, "panel_a.rds"))
p_panel_b <- readRDS(file.path(artifacts_dir, "panel_b.rds"))
p_panel_c <- readRDS(file.path(artifacts_dir, "panel_c.rds"))
p_panel_d <- readRDS(file.path(artifacts_dir, "panel_d.rds"))

# Panel A on the left; Panels B, C, D stacked top-to-bottom on the right.
# Three stacked panels need to fit the mandated 10x8 canvas (EXPORT_STANDARD.md)
# without shrinking text below the 10-12pt manuscript-readability floor
# (EXPORT_STANDARD.md) or the panel tag below 14pt (PANEL_TAGGING_STANDARD.md),
# so room is made through layout instead: the right column gets substantially
# more relative width than the left, and the plot margins around each panel
# are tightened (applied via the shared `&` theme so all four panels,
# including the untouched B/C, stay visually consistent).
# ASSUMED[no exact proportions given]: left:right column width ratio of 1:1.6
# and the tightened margins below, chosen so three stacked panels stay legible
# within the standard 8-inch height while keeping all text >=10pt and the tag
# at 14pt.
p_final <- (p_panel_a | (p_panel_b / p_panel_c / p_panel_d)) +
  plot_layout(widths = c(1, 1.6)) +
  plot_annotation(tag_levels = "A") &
  theme(
    plot.tag      = element_text(face = "bold", size = 14),
    axis.title    = element_text(size = 10),
    axis.text     = element_text(size = 10),
    legend.text   = element_text(size = 10),
    legend.title  = element_text(size = 10),
    plot.margin   = margin(t = 2, r = 4, b = 2, l = 4)
  )

plot_name <- "regression_results"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_final, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_final, width = 10, height = 8, dpi = 300, bg = "white")

#### ASSEMBLE COMPOSITE FIGURE ####
# reads: artifacts/panel_a.rds, artifacts/panel_b.rds, artifacts/panel_c.rds, artifacts/panel_d.rds · writes: output/regression_results.pdf, output/regression_results.png

p_panel_a <- readRDS(file.path(artifacts_dir, "panel_a.rds"))
p_panel_b <- readRDS(file.path(artifacts_dir, "panel_b.rds"))
p_panel_c <- readRDS(file.path(artifacts_dir, "panel_c.rds"))
p_panel_d <- readRDS(file.path(artifacts_dir, "panel_d.rds"))

# Panel A on the left; Panels B, C, D stacked top-to-bottom on the right.
# Four panels need to fit the mandated 10x8 canvas (EXPORT_STANDARD.md).
# Panel tags stay at the mandated bold/14pt (PANEL_TAGGING_STANDARD.md -
# Mandatory Style is not a layout knob). The left:right column width ratio of
# 1:1.3 is spec-given (card PROJECT STATE: assemble_figure.R must preserve the
# standard 10x8 canvas via `plot_layout(widths = c(1, 1.3))`), not a Writer
# decision. Legibility for three stacked panels is instead recovered by
# tightening plot margins so the stacked B/C/D panels lose less vertical
# space to padding. Body text (axis titles/text, legend text/title) is kept
# within the 10-12pt band required by EXPORT_STANDARD.md's checklist.
# ASSUMED[no exact figure given]: exact margin values and exact text point
# sizes within the >=10pt floor, chosen so three stacked panels stay legible
# within the standard 8-inch height.
p_final <- (p_panel_a | (p_panel_b / p_panel_c / p_panel_d)) +
  plot_layout(widths = c(1, 1.3)) +
  plot_annotation(tag_levels = "A") &
  theme(
    plot.tag      = element_text(face = "bold", size = 14),
    plot.margin   = margin(t = 3, r = 4, b = 3, l = 4, unit = "pt"),
    axis.title    = element_text(size = 11),
    axis.text     = element_text(size = 10),
    legend.text   = element_text(size = 10),
    legend.title  = element_text(size = 11),
    legend.key.size = unit(0.6, "lines"),
    legend.margin    = margin(0, 0, 0, 0),
    legend.box.spacing = unit(2, "pt")
  )

plot_name <- "regression_results"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_final, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_final, width = 10, height = 8, dpi = 300, bg = "white")

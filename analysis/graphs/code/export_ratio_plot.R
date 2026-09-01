#### EXPORT RATIO COMPARISON PLOT ####
# reads: artifacts/ratio_comparison_plot.rds · writes: output/ratio_comparison.pdf, output/ratio_comparison.png

p_ratio_comparison <- readRDS(file.path(artifacts_dir, "ratio_comparison_plot.rds"))

# Redesigned from a 9-row stacked ridgeline (which needed the grown 11in
# height below to keep each row legible) into a single overlay at one shared
# baseline, so the standard EXPORT_STANDARD.md dimensions (10x8in) fit
# comfortably again - there are no more independent rows to fit.
plot_name <- "ratio_comparison"

ggsave(file.path(output_dir, paste0(plot_name, ".pdf")),
       plot = p_ratio_comparison, width = 10, height = 8, bg = "white")

ggsave(file.path(output_dir, paste0(plot_name, ".png")),
       plot = p_ratio_comparison, width = 10, height = 8, dpi = 300, bg = "white")

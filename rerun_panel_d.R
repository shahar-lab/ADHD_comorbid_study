#### RE-RUN PANEL D + REASSEMBLE FIGURE FOR ALL REGRESSION_ANALYSIS FOLDERS ####
# Reuses each folder's existing model_fit.rds / posterior_draws.rds / panel_a.rds /
# panel_b.rds / panel_c.rds on disk - only regenerates panel_d.rds (new custom
# point + text legend/index: blue point = "with ADHD", orange point = "without
# ADHD") and the final composite regression_results.pdf/.png.
# Skips fit_model.R and check_diagnostics.R entirely, so this is fast (no
# brms refit) instead of re-running each folder's full main.R.
#
# ICAR has no Panel D (no established clinical cutoff for that measure), so
# it is not included here - see rerun_panel_b.R / rerun_panel_c.R for ICAR.

library(here)
library(tidyverse)
library(ggdist)
library(patchwork)

folders <- c(
  "aq_regression_analysis", "asrs_regression_analysis", "wurs_regression_analysis",
  "bdi_regression_analysis", "ocir_regression_analysis", "pqb_regression_analysis",
  "stai_state_regression_analysis", "stai_trait_regression_analysis"
)

project_root <- here::here()

for (folder in folders) {
  cat("== Updating Panel D:", folder, "==\n")

  code_dir      <- file.path(project_root, "analysis", folder, "code")
  artifacts_dir <- file.path(project_root, "analysis", folder, "artifacts")
  output_dir    <- file.path(project_root, "analysis", folder, "output")

  source(file.path(code_dir, "plot_panel_d.R"))
  source(file.path(code_dir, "assemble_figure.R"))
}

cat("Done. All 8 regression_results.pdf/.png files regenerated with the new Panel D legend.\n")

#### RE-RUN PANEL C + REASSEMBLE FIGURE FOR ALL REGRESSION_ANALYSIS FOLDERS ####
# Reuses each folder's existing model_fit.rds / posterior_draws.rds / panel_a.rds /
# panel_b.rds / panel_d.rds on disk - only regenerates panel_c.rds (new fixed
# x-axis, -0.5 to 1.5) and the final composite regression_results.pdf/.png.
# Skips fit_model.R and check_diagnostics.R entirely, so this is fast (no
# brms refit) instead of re-running each folder's full main.R.

library(here)
library(tidyverse)
library(ggdist)
library(patchwork)

folders <- c(
  "aq_regression_analysis", "asrs_regression_analysis", "wurs_regression_analysis",
  "bdi_regression_analysis", "ocir_regression_analysis", "pqb_regression_analysis",
  "stai_state_regression_analysis", "stai_trait_regression_analysis",
  "icar_regression_analysis"
)

project_root <- here::here()

for (folder in folders) {
  cat("== Updating Panel C:", folder, "==\n")

  code_dir      <- file.path(project_root, "analysis", folder, "code")
  artifacts_dir <- file.path(project_root, "analysis", folder, "artifacts")
  output_dir    <- file.path(project_root, "analysis", folder, "output")

  source(file.path(code_dir, "plot_panel_c.R"))
  source(file.path(code_dir, "assemble_figure.R"))
}

cat("Done. All 9 regression_results.pdf/.png files regenerated with the new Panel C.\n")

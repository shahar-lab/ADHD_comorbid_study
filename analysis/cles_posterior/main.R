rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
library(brms)
library(posterior)
library(ggdist)
library(patchwork)

# here::here() anchors to the .Rproj root regardless of the working directory,
# so paths resolve identically on any machine without setwd() gymnastics.
project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "cles_posterior", "code")
artifacts_dir <- file.path(project_root, "analysis", "cles_posterior", "artifacts")
output_dir    <- file.path(project_root, "analysis", "cles_posterior", "output")
# No data_path: this folder reads no data/processed_data stage directly. It
# reuses the already-fitted model_fit.rds and df_regression.rds artifacts
# already produced by the 9 sibling analysis/*_regression_analysis/ folders.



#### EXECUTE PIPELINE ####

# 1. Posterior CLES: per-draw CLES = pnorm(b_group_declaredADHD / (sqrt(2)*sigma))
# from each sibling model's existing posterior draws, for all 9 outcomes (saves to artifacts/)
source(file.path(code_dir, "compute_posterior_cles.R"))

# 2. Observed-data CLES: full pairwise ADHD x TD comparison from each sibling's
# raw df_regression.rds, for all 9 outcomes (saves to artifacts/)
source(file.path(code_dir, "compute_observed_cles.R"))

# 3. Comparison table: merges posterior + observed CLES, prints the full console
# report and sanity checks, writes both CSV deliverables (saves to output/)
source(file.path(code_dir, "build_summary_table.R"))

# 4. Panel A: faceted posterior CLES distributions, one facet per measure (saves to artifacts/)
source(file.path(code_dir, "plot_panel_a.R"))

# 5. Panel B: observed vs. posterior CLES forest plot across all measures (saves to artifacts/)
source(file.path(code_dir, "plot_panel_b.R"))

# 6. Assemble Panels A+B into the final tagged composite figure (saves to output/)
source(file.path(code_dir, "assemble_figure.R"))

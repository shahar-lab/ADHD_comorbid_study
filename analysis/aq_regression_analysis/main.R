rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
library(brms)
library(bayesplot)
library(posterior)
library(ggdist)
library(patchwork)
library(gridExtra)
library(effsize)

# here::here() anchors to the .Rproj root regardless of the working directory,
# so paths resolve identically on any machine without setwd() gymnastics.
project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "aq_regression_analysis", "code")
artifacts_dir <- file.path(project_root, "analysis", "aq_regression_analysis", "artifacts")
output_dir    <- file.path(project_root, "analysis", "aq_regression_analysis", "output")
# Project CLAUDE.md directs all analysis to this specific processed-data file,
# which lives at data/processed_data/, not the generic data/processed/ default.
data_path     <- file.path(project_root, "data", "processed_data")



#### EXECUTE PIPELINE ####

# 1. Data preparation: loads the canonical processed dataframe, releveled so
# TD is the reference group (saves to artifacts/)
source(file.path(code_dir, "prep_data.R"))

# 2. Model fitting: aq ~ group_declared, user-approved priors (saves to artifacts/)
source(file.path(code_dir, "fit_model.R"))

# 3. Diagnostics: ess/rhat table, trankplot, pairs plot (saves to output/)
source(file.path(code_dir, "check_diagnostics.R"))

# 4. Extract posterior draws needed for all three plot panels (saves to artifacts/)
source(file.path(code_dir, "extract_posteriors.R"))

# 5. Panel A: empirical strip plot + posterior group-mean predictions
source(file.path(code_dir, "plot_panel_a.R"))

# 6. Panel B: effect posterior (ADHD - TD)
source(file.path(code_dir, "plot_panel_b.R"))

# 7. Sub-panel C: posterior ratio (ADHD mean / TD mean)
source(file.path(code_dir, "plot_panel_c.R"))

# 8. Panel D: posterior proportion of each group above the clinical cutoff
source(file.path(code_dir, "plot_panel_d.R"))

# 8b. Numeric summary of Panel D: median + 90% CI of proportion above cutoff per group (saves to output/)
source(file.path(code_dir, "summarize_cutoff_proportions.R"))

# 9. Assemble composite figure (A left, B/C/D stacked right; saves to output/)
source(file.path(code_dir, "assemble_figure.R"))

# 10. Simulate 464 AQ scores from posterior draws of the fitted model (saves to artifacts/)
source(file.path(code_dir, "simulate_aq_from_posterior.R"))

# 11. Simulated AQ overview, descriptives, skew/kurtosis, outliers (read-only; saves tables to output/)
source(file.path(code_dir, "summarize_simulated_aq_descriptives.R"))

# 12. Simulated AQ group difference, assumption checks, model-implied comparison (read-only; saves table to output/)
source(file.path(code_dir, "summarize_simulated_aq_comparison.R"))

# 13. Diagnostic plots (histogram/density + Q-Q) for the simulated AQ dataset (saves to output/)
source(file.path(code_dir, "plot_simulated_aq_diagnostics.R"))

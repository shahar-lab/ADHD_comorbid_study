rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
library(brms)
library(bayesplot)
library(posterior)
library(gridExtra)
library(knitr)

# here::here() anchors to the .Rproj root regardless of the working directory,
# so paths resolve identically on any machine without setwd() gymnastics.
project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "cles", "code")
artifacts_dir <- file.path(project_root, "analysis", "cles", "artifacts")
output_dir    <- file.path(project_root, "analysis", "cles", "output")
# Project CLAUDE.md directs all analysis to this specific processed-data file,
# which lives at data/processed_data/, not the generic data/processed/ default.
data_path     <- file.path(project_root, "data", "processed_data")



#### EXECUTE PIPELINE ####

# 1. Load df_remove_diagnosis_contradiction.Rdata, keep the 10 questionnaire
# columns, TD releveled as reference (saves to artifacts/)
source(file.path(code_dir, "prep_data.R"))

# 2. Fit one heteroskedastic model per questionnaire: <score> ~ group_declared,
# sigma ~ group_declared, user-approved mean + sigma priors (saves to artifacts/)
source(file.path(code_dir, "fit_models.R"))

# 3. Diagnostics for all 10 models: ess/rhat table, trankplot, pairs plot per
# model, one consolidated PDF (saves to output/)
source(file.path(code_dir, "check_diagnostics.R"))

# 4. Extract per-draw diff/Cohen's d/CLES/Odds/Risk Ratio from each model's
# posterior (saves to artifacts/)
source(file.path(code_dir, "extract_posterior_effects.R"))

# 5. Summarize into the main CLES table (median + 90% CrI per measure) and a
# supplementary sample-size table (saves to output/)
source(file.path(code_dir, "summarize_effects_table.R"))

# 6. Non-parametric Mann-Whitney CLES cross-check against the Bayesian median
# CLES (saves to output/)
source(file.path(code_dir, "crosscheck_nonparametric_cles.R"))

# 7. Interpretation note (saves to output/)
source(file.path(code_dir, "write_interpretation_note.R"))

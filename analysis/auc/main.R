rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
library(pROC)

# here::here() anchors to the .Rproj root regardless of the working directory,
# so paths resolve identically on any machine without setwd() gymnastics.
project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "auc", "code")
artifacts_dir <- file.path(project_root, "analysis", "auc", "artifacts")
output_dir    <- file.path(project_root, "analysis", "auc", "output")
# Project CLAUDE.md directs all analysis to this specific processed-data file,
# which lives at data/processed_data/, not the generic data/processed/ default.
data_path     <- file.path(project_root, "data", "processed_data")



#### EXECUTE PIPELINE ####

# 1. Load df_remove_diagnosis_contradiction.Rdata, build one complete-case long
# table (subjectid, group_declared, questionnaire, score) covering all 10
# questionnaires (saves to artifacts/)
source(file.path(code_dir, "prep_data.R"))

# 2. Fit one ROC curve per questionnaire (direction fixed per spec, ICAR auto),
# compute AUC/CI/p-value/Youden cutoff/sensitivity/specificity/PPV/NPV (saves
# to artifacts/)
source(file.path(code_dir, "fit_roc_curves.R"))

# 3. Build the summary table + supplementary sample-size/direction table (saves
# to output/roc_summary_table.csv, output/roc_sample_sizes.csv)
source(file.path(code_dir, "summarize_roc_table.R"))

# 4. Individual ROC plots, one per questionnaire (saves to output/)
source(file.path(code_dir, "plot_roc_individual.R"))

# 5. Combined ROC plot overlaying all 10 curves (saves to output/)
source(file.path(code_dir, "plot_roc_combined.R"))

# 6. Pairwise DeLong AUC comparisons on common-case subsamples, Holm-corrected
# (saves to output/pairwise_auc_comparisons.csv)
source(file.path(code_dir, "compare_auc_pairwise.R"))

# 7. Results paragraph and cutoff-methodology note (saves to output/)
source(file.path(code_dir, "write_reports.R"))

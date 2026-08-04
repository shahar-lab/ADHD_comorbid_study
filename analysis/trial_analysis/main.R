rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
library(patchwork)

# here::here() anchors to the .Rproj root regardless of the working directory,
# so paths resolve identically on any machine without setwd() gymnastics.
project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "trial_analysis", "code")
artifacts_dir <- file.path(project_root, "analysis", "trial_analysis", "artifacts")
output_dir    <- file.path(project_root, "analysis", "trial_analysis", "output")
data_path     <- file.path(project_root, "data", "processed_data")



#### EXECUTE PIPELINE ####

# 1. Data Preparation
# Reads the canonical processed dataframe. Per the Artifacts Rule, never copy
# data into this folder.
source(file.path(code_dir, "prep_data.R"))

# 2. BDI severity prep (builds on df from prep_data.R; drops missing bdi,
# adds bdi_transformed and the severity factor)
source(file.path(code_dir, "prep_bdi_severity.R"))

# 3. Plotting (saves to output/)
source(file.path(code_dir, "plot_selfreport_dothistograms.R"))

# 4. BDI severity summary tables (saves to output/)
source(file.path(code_dir, "summarize_bdi_severity.R"))

# 5. BDI strip plots by group (saves to output/)
source(file.path(code_dir, "plot_bdi_stripplot_transformed.R"))
source(file.path(code_dir, "plot_bdi_stripplot_raw.R"))

# 6. Second self-report distribution figure: STAI-Trait, STAI-State, ICAR
# (df from prep_data.R already carries these columns; saves to output/)
source(file.path(code_dir, "plot_selfreport_dothistograms_2.R"))

# 7. STAI-Trait severity: binary cutoff (>=40), prep + summary + strip plot (raw + transformed)
source(file.path(code_dir, "prep_stai_trait_severity.R"))
source(file.path(code_dir, "summarize_stai_trait_severity.R"))
source(file.path(code_dir, "plot_stai_trait_stripplot_raw.R"))
source(file.path(code_dir, "plot_stai_trait_stripplot_transformed.R"))

# 8. STAI-State severity: binary cutoff (>=40), prep + summary + strip plot (raw + transformed)
source(file.path(code_dir, "prep_stai_state_severity.R"))
source(file.path(code_dir, "summarize_stai_state_severity.R"))
source(file.path(code_dir, "plot_stai_state_stripplot_raw.R"))
source(file.path(code_dir, "plot_stai_state_stripplot_transformed.R"))

# 9. OCI-R severity: binary cutoff (>=21), prep + summary + strip plot (raw + transformed)
source(file.path(code_dir, "prep_ocir_severity.R"))
source(file.path(code_dir, "summarize_ocir_severity.R"))
source(file.path(code_dir, "plot_ocir_stripplot_raw.R"))
source(file.path(code_dir, "plot_ocir_stripplot_transformed.R"))

# 10. AQ severity: binary cutoff (>=32), prep + summary + strip plot (raw + transformed)
source(file.path(code_dir, "prep_aq_severity.R"))
source(file.path(code_dir, "summarize_aq_severity.R"))
source(file.path(code_dir, "plot_aq_stripplot_raw.R"))
source(file.path(code_dir, "plot_aq_stripplot_transformed.R"))

# Note: ICAR gets distribution-only treatment (step 6) - no severity cutoff
# exists for a cognitive-ability measure. patas_sum and pqb are explicitly
# excluded from this analysis folder (user decision, not an oversight).

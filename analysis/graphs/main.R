rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
# No ggdist: the density curves are computed with stats::density() and the
# point/credible-interval marks with plain ggplot2 geoms (see
# code/build_ratio_plot.R for why ggdist's stat_pointinterval was dropped).

# here::here() anchors to the .Rproj root regardless of the working directory,
# so paths resolve identically on any machine without setwd() gymnastics.
project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "graphs", "code")
artifacts_dir <- file.path(project_root, "analysis", "graphs", "artifacts")
output_dir    <- file.path(project_root, "analysis", "graphs", "output")
# This folder is a cross-analysis comparison, not a model fit on data/: it
# reads already-computed posterior draws from nine sibling analysis/ folders'
# artifacts/, so it defines no data_path (project-rules.md's Artifacts Rule
# bounds WRITING to this folder, not reading sibling artifacts).



#### EXECUTE PIPELINE ####

# 1. Read $ratio posterior draws from the 9 sibling regression analyses'
# artifacts/posterior_draws.rds and combine into one long tibble (saves to artifacts/)
source(file.path(code_dir, "load_ratio_draws.R"))

# 2. Fix the legend order/colours and compute the shared x-axis window
# (saves to artifacts/)
source(file.path(code_dir, "prep_ratio_plot_layout.R"))

# 3. Build the overlaid comparison of the ratio posteriors across all 9
# measures, all sharing one y = 0 baseline (saves to artifacts/)
source(file.path(code_dir, "build_ratio_plot.R"))

# 4. Export the overlaid comparison as PDF + PNG (saves to output/)
source(file.path(code_dir, "export_ratio_plot.R"))

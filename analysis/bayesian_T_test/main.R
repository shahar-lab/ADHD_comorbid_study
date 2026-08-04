rm(list = ls())

#### SETUP ####

library(here)
library(tidyverse)
library(BayesFactor)
library(ggdist)
library(coda)
library(posterior)
library(bayesplot)
library(gridExtra)

# here::here() anchors to the .Rproj root regardless of the working directory,
# so paths resolve identically on any machine without setwd() gymnastics.
project_root  <- here::here()
code_dir      <- file.path(project_root, "analysis", "bayesian_T_test", "code")
artifacts_dir <- file.path(project_root, "analysis", "bayesian_T_test", "artifacts")
output_dir    <- file.path(project_root, "analysis", "bayesian_T_test", "output")
data_path     <- file.path(project_root, "data", "processed_data")



#### EXECUTE PIPELINE ####

# 1. Data preparation: ADHD vs TD, non-missing AQ
source(file.path(code_dir, "prep_data.R"))

# 2. Bayes factor (BayesFactor::ttestBF, default Cauchy prior, two-sided,
# unrestricted alternative). Saves bf_object.rds to artifacts/
source(file.path(code_dir, "fit_bayes_factor.R"))

# 3. Posterior draws of the standardized effect size delta, sampled as 4
# independent chains from the same JZS model as the BF above
# (BayesFactor::posterior()). Saves draws to artifacts/
source(file.path(code_dir, "fit_posterior_delta.R"))

# 4. Posterior-of-delta plot via the /plot-posterior skill convention. Saves
# to output/
source(file.path(code_dir, "plot_posterior_delta.R"))

# 5. Mandatory MCMC diagnostics (rhat/ess summary table, trankplot, pairs
# plot) per the bayesian-regression skill. Saves diagnostic.pdf to output/
source(file.path(code_dir, "diagnostics.R"))

# 6. Console report: BF10/BF01, posterior d + 95% CrI, sign-convention check,
# directional interpretation
source(file.path(code_dir, "report_results.R"))

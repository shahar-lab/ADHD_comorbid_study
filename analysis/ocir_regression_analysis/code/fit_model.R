#### FIT BAYESIAN REGRESSION: OCIR ~ GROUP ####
# reads: artifacts/df_regression.rds · writes: artifacts/model_fit.rds

df <- readRDS(file.path(artifacts_dir, "df_regression.rds"))

# User-approved priors. TD is the reference level, so Intercept = TD mean
# (weakly informative, anchored to this project's own OCIR descriptives,
# TD mean ~= 13.8) and the single "b" coefficient = ADHD - TD (raw ocir
# scale, no standardization needed).
regression_priors <- c(
  prior(normal(14, 10), class = "Intercept"),
  prior(normal(0, 10), class = "b"),
  prior(exponential(0.1), class = "sigma")
)

# backend = "rstan" per the given spec/precedent (cmdstanr confirmed
# unusable on this machine, already worked around in aq_regression_analysis
# and bdi_regression_analysis).
model_fit <- brm(
  formula = ocir ~ group_declared,
  data    = df,
  family  = gaussian(),
  prior   = regression_priors,
  chains  = 4,
  iter    = 2000,
  warmup  = 1000,
  backend = "rstan",
  cores   = 4,
  seed    = 1234
)

saveRDS(model_fit, file.path(artifacts_dir, "model_fit.rds"))

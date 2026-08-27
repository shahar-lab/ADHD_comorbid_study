#### FIT BAYESIAN REGRESSION: ASRS ~ GROUP ####
# reads: artifacts/df_regression.rds · writes: artifacts/model_fit.rds

df <- readRDS(file.path(artifacts_dir, "df_regression.rds"))

# User-approved priors. TD is the reference level, so Intercept = TD mean
# (weakly informative, anchored to the 0-4 scored 18-item ASRS-v1.1 scale)
# and the single "b" coefficient = ADHD - TD (raw asrs scale, no
# standardization needed).
regression_priors <- c(
  prior(normal(18, 10), class = "Intercept"),
  prior(normal(0, 15), class = "b"),
  prior(exponential(0.08), class = "sigma")
)

# backend = "rstan", per spec - cmdstanr unavailable on this machine
# (toolchain version-check mismatch, see PROJECT STATE).
# seed = 1234, per spec, for reproducibility.
model_fit <- brm(
  formula = asrs ~ group_declared,
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

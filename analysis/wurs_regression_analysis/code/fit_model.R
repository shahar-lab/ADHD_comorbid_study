#### FIT BAYESIAN REGRESSION: WURS ~ GROUP ####
# reads: artifacts/df_regression.rds · writes: artifacts/model_fit.rds

df <- readRDS(file.path(artifacts_dir, "df_regression.rds"))

# User-approved priors. TD is the reference level, so Intercept = TD mean
# (weakly informative, anchored to the WURS-25 scale) and the single "b"
# coefficient = ADHD - TD (raw wurs scale, no standardization needed).
regression_priors <- c(
  prior(normal(13, 10), class = "Intercept"),
  prior(normal(0, 20), class = "b"),
  prior(exponential(0.06), class = "sigma")
)

# backend = rstan, per spec - cmdstanr unavailable on this machine
# (toolchain version-check mismatch, see PROJECT STATE).
# seed = 1234, per spec.
model_fit <- brm(
  formula = wurs ~ group_declared,
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

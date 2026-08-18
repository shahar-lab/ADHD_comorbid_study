#### FIT BAYESIAN REGRESSION: AQ ~ GROUP ####
# reads: artifacts/df_regression.rds · writes: artifacts/model_fit.rds

df <- readRDS(file.path(artifacts_dir, "df_regression.rds"))

# User-approved priors. TD is the reference level, so Intercept = TD mean
# (weakly informative, anchored to the AQ-50 scale) and the single "b"
# coefficient = ADHD - TD (raw aq scale, no standardization needed).
regression_priors <- c(
  prior(normal(20, 10), class = "Intercept"),
  prior(normal(0, 10), class = "b"),
  prior(exponential(0.1), class = "sigma")
)

# ASSUMED[cmdstanr unavailable on this machine - toolchain version-check
# mismatch, see PROJECT STATE]: backend = "rstan" substituted for cmdstanr.
# ASSUMED[no seed value given, only "for reproducibility" requested]: seed = 1234.
model_fit <- brm(
  formula = aq ~ group_declared,
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

#### FIT BAYESIAN REGRESSION: PATAS ~ GROUP ####
# reads: artifacts/df_regression.rds · writes: artifacts/model_fit.rds

df <- readRDS(file.path(artifacts_dir, "df_regression.rds"))

# User-approved priors. TD is the reference level, so Intercept = TD mean and
# the single "b" coefficient = ADHD - TD (raw patas_sum scale, no
# standardization needed).
regression_priors <- c(
  prior(normal(16, 10), class = "Intercept"),
  prior(normal(0, 12), class = "b"),
  prior(exponential(0.1), class = "sigma")
)

# Per specification: backend = "rstan" and seed = 1234 given directly.
model_fit <- brm(
  formula = patas_sum ~ group_declared,
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

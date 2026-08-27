#### FIT BAYESIAN REGRESSION: PQB ~ GROUP ####
# reads: artifacts/df_regression.rds · writes: artifacts/model_fit.rds

df <- readRDS(file.path(artifacts_dir, "df_regression.rds"))

# User-approved priors. TD is the reference level, so Intercept = TD mean
# (weakly informative, anchored to the PQ-B 0-21 item-count scale) and the
# single "b" coefficient = ADHD - TD (raw pqb scale, no standardization needed).
regression_priors <- c(
  prior(normal(2, 5), class = "Intercept"),
  prior(normal(0, 5), class = "b"),
  prior(exponential(0.25), class = "sigma")
)

# backend = rstan, per spec — cmdstanr unavailable on this machine
# (toolchain version-check mismatch, established precedent from every
# sibling regression analysis).
model_fit <- brm(
  formula = pqb ~ group_declared,
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

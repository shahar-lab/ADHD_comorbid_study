#### FIT ONE HETEROSKEDASTIC BAYESIAN MODEL PER QUESTIONNAIRE ####
# reads: artifacts/df_full.rds · writes: artifacts/model_fits.rds, artifacts/questionnaire_specs.rds

df_full <- readRDS(file.path(artifacts_dir, "df_full.rds"))

# Domain-table order (per spec). Mean-submodel priors (intercept_mean/sd, b_sd,
# b_mean = 0) are reused verbatim from each sibling *_regression_analysis
# model's already-approved priors. Sigma-submodel priors are new (log link,
# dpar = "sigma"): sigma Intercept mean = log of the sibling model's
# exponential(rate) sigma-prior mean; sigma Intercept/b SD fixed at 0.5 for
# every questionnaire, all user-approved.
questionnaire_specs <- tibble(
  questionnaire        = c("asrs", "wurs", "aq", "stai_state", "stai_trait",
                            "bdi", "ocir", "pqb", "patas_sum", "icar"),
  domain               = c("ADHD symptoms", "ADHD symptoms", "Autistic traits",
                            "Anxiety", "Anxiety", "Depression", "Obsessive-Compulsive",
                            "Psychosis-related", "Attitudes", "Cognitive ability"),
  label                = c("ASRS", "WURS", "AQ", "STAI-State", "STAI-Trait",
                            "BDI", "OCI-R", "PQ-B", "PATAS", "ICAR"),
  intercept_mean       = c(18, 13, 20, 15, 16, 10, 14, 2, 16, 9),
  intercept_sd         = c(10, 10, 10, 10, 10, 10, 10, 5, 10, 5),
  b_sd                 = c(15, 20, 10, 12, 12, 10, 10, 5, 12, 5),
  sigma_intercept_mean = c(2.526, 2.813, 2.303, 2.526, 2.526, 2.303, 2.303, 1.386, 2.303, 1.386),
  cutoff               = c(40, 36, 32, 40, 44, 14, 21, 7, NA, NA)
)

model_fits <- list()

for (i in seq_len(nrow(questionnaire_specs))) {
  spec   <- questionnaire_specs[i, ]
  q_name <- spec$questionnaire

  df_q <- df_full |> filter(!is.na(.data[[q_name]]))

  q_priors <- c(
    set_prior(sprintf("normal(%g, %g)", spec$intercept_mean, spec$intercept_sd), class = "Intercept"),
    set_prior(sprintf("normal(0, %g)", spec$b_sd), class = "b"),
    set_prior(sprintf("normal(%g, 0.5)", spec$sigma_intercept_mean), class = "Intercept", dpar = "sigma"),
    set_prior("normal(0, 0.5)", class = "b", dpar = "sigma")
  )

  # backend = "rstan", per spec - cmdstanr unavailable on this machine
  # (toolchain version-check mismatch, matching every sibling model in this repo).
  model_fit <- brm(
    formula = bf(as.formula(paste(q_name, "~ group_declared")), sigma ~ group_declared),
    data    = df_q,
    family  = gaussian(),
    prior   = q_priors,
    chains  = 4,
    iter    = 2000,
    warmup  = 1000,
    backend = "rstan",
    cores   = 4,
    seed    = 1234
  )

  model_fits[[q_name]] <- model_fit
}

saveRDS(model_fits, file.path(artifacts_dir, "model_fits.rds"))
saveRDS(questionnaire_specs, file.path(artifacts_dir, "questionnaire_specs.rds"))

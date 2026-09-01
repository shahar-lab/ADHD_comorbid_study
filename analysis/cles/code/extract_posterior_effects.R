#### EXTRACT PER-DRAW DIFF / COHEN'S D / CLES / ODDS / RISK RATIO ####
# reads: artifacts/model_fits.rds, artifacts/questionnaire_specs.rds · writes: artifacts/posterior_effects.rds

model_fits          <- readRDS(file.path(artifacts_dir, "model_fits.rds"))
questionnaire_specs <- readRDS(file.path(artifacts_dir, "questionnaire_specs.rds"))

newdata_groups <- tibble(group_declared = factor(c("TD", "ADHD"), levels = c("TD", "ADHD")))

posterior_effects <- list()

for (i in seq_len(nrow(questionnaire_specs))) {
  q_name    <- questionnaire_specs$questionnaire[i]
  cutoff    <- questionnaire_specs$cutoff[i]
  model_fit <- model_fits[[q_name]]

  # posterior_epred() on the identity-link mean submodel gives per-draw group
  # means directly; on the log-link sigma submodel with dpar = "sigma" it
  # returns per-group sigma already back-transformed to the response scale.
  mu_draws    <- posterior_epred(model_fit, newdata = newdata_groups)
  sigma_draws <- posterior_epred(model_fit, newdata = newdata_groups, dpar = "sigma")

  mu_td      <- mu_draws[, 1]
  mu_adhd    <- mu_draws[, 2]
  sigma_td   <- sigma_draws[, 1]
  sigma_adhd <- sigma_draws[, 2]

  diff_draws     <- mu_adhd - mu_td
  cles_draws     <- pnorm(diff_draws / sqrt(sigma_adhd^2 + sigma_td^2))
  odds_draws     <- cles_draws / (1 - cles_draws)
  cohens_d_draws <- diff_draws / sqrt((sigma_adhd^2 + sigma_td^2) / 2)

  rr_draws <- if (!is.na(cutoff)) {
    p_above_adhd <- pnorm(cutoff, mean = mu_adhd, sd = sigma_adhd, lower.tail = FALSE)
    p_above_td   <- pnorm(cutoff, mean = mu_td, sd = sigma_td, lower.tail = FALSE)
    p_above_adhd / p_above_td
  } else {
    NA
  }

  posterior_effects[[q_name]] <- tibble(
    diff = diff_draws, cohens_d = cohens_d_draws,
    cles = cles_draws, odds = odds_draws, rr = rr_draws
  )
}

saveRDS(posterior_effects, file.path(artifacts_dir, "posterior_effects.rds"))

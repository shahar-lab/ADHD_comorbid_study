#### COMPUTE POSTERIOR CLES PER OUTCOME ####
# reads: ../<measure>_regression_analysis/artifacts/model_fit.rds (9 sibling analyses)
# writes: artifacts/posterior_cles_draws.rds

# Homoskedastic (single shared sigma) models already fitted and approved in
# each sibling analysis/*_regression_analysis/ folder. No refitting here.
measures <- tibble(
  folder  = c("aq_regression_analysis", "asrs_regression_analysis", "wurs_regression_analysis",
              "bdi_regression_analysis", "ocir_regression_analysis", "pqb_regression_analysis",
              "stai_state_regression_analysis", "stai_trait_regression_analysis", "icar_regression_analysis"),
  outcome = c("aq", "asrs", "wurs", "bdi", "ocir", "pqb", "stai_state", "stai_trait", "icar"),
  label   = c("AQ", "ASRS", "WURS", "BDI", "OCI-R", "PQ-B", "STAI-State", "STAI-Trait", "ICAR")
)

# Target 10,000 draws/outcome; if a model has fewer, use all and report the
# actual count (true for all 9 here: chains=4, iter=2000, warmup=1000 -> 4000
# post-warmup draws). If more than 10,000 existed, subsample with this seed.
target_draws <- 10000
set.seed(12345)

posterior_cles_list <- vector("list", nrow(measures))

for (i in seq_len(nrow(measures))) {
  model_fit <- readRDS(file.path(project_root, "analysis", measures$folder[i], "artifacts", "model_fit.rds"))
  draws     <- as_draws_df(model_fit)

  b_intercept <- draws$b_Intercept
  b_group     <- draws$b_group_declaredADHD
  sigma_draws <- draws$sigma
  n_draws     <- length(b_intercept)

  if (n_draws > target_draws) {
    keep        <- sample(seq_len(n_draws), target_draws)
    b_intercept <- b_intercept[keep]
    b_group     <- b_group[keep]
    sigma_draws <- sigma_draws[keep]
    n_draws     <- target_draws
  }

  # CLES = P(Y_ADHD > Y_TD) = Phi(b_1 / (sqrt(2) * sigma)), one value per draw
  # -- posterior parameter uncertainty propagated directly, no simulated participants.
  cles_draws <- pnorm(b_group / (sqrt(2) * sigma_draws))

  posterior_cles_list[[i]] <- tibble(
    outcome              = measures$outcome[i],
    posterior_draw        = seq_len(n_draws),
    b_Intercept            = b_intercept,
    b_group_declaredADHD  = b_group,
    sigma                  = sigma_draws,
    TD_mean                = b_intercept,
    ADHD_mean              = b_intercept + b_group,
    CLES                   = cles_draws
  )

  cat(sprintf("%-12s: %d posterior draws used | sigma > 0 for all draws: %s\n",
              measures$label[i], n_draws, all(sigma_draws > 0)))
}

posterior_cles_draws <- bind_rows(posterior_cles_list)

cat("CLES finite and in [0, 1] for all draws, all outcomes:",
    all(is.finite(posterior_cles_draws$CLES)) &
      all(posterior_cles_draws$CLES >= 0 & posterior_cles_draws$CLES <= 1), "\n")

saveRDS(posterior_cles_draws, file.path(artifacts_dir, "posterior_cles_draws.rds"))

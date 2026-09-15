#### COMPUTE OBSERVED-DATA CLES PER OUTCOME ####
# reads: ../<measure>_regression_analysis/artifacts/df_regression.rds (9 sibling analyses)
# writes: artifacts/observed_cles.rds

# Real observed scores only -- never a simulated/synthetic dataset (e.g.
# simulated_aq_from_posterior.csv is explicitly out of scope here).
measures <- tibble(
  folder  = c("aq_regression_analysis", "asrs_regression_analysis", "wurs_regression_analysis",
              "bdi_regression_analysis", "ocir_regression_analysis", "pqb_regression_analysis",
              "stai_state_regression_analysis", "stai_trait_regression_analysis", "icar_regression_analysis"),
  outcome = c("aq", "asrs", "wurs", "bdi", "ocir", "pqb", "stai_state", "stai_trait", "icar"),
  label   = c("AQ", "ASRS", "WURS", "BDI", "OCI-R", "PQ-B", "STAI-State", "STAI-Trait", "ICAR")
)

observed_cles_list <- vector("list", nrow(measures))

for (i in seq_len(nrow(measures))) {
  df          <- readRDS(file.path(project_root, "analysis", measures$folder[i], "artifacts", "df_regression.rds"))
  outcome_col <- measures$outcome[i]

  adhd_scores <- df[[outcome_col]][df$group_declared == "ADHD"]
  td_scores   <- df[[outcome_col]][df$group_declared == "TD"]
  n_adhd      <- length(adhd_scores)
  n_td        <- length(td_scores)

  # Full pairwise comparison, vectorized via outer() -- feasible at these Ns,
  # not approximated by sampling pairs.
  pair_sign <- outer(adhd_scores, td_scores, FUN = function(a, t) sign(a - t))
  n_pairs   <- n_adhd * n_td
  n_greater <- sum(pair_sign > 0)
  n_ties    <- sum(pair_sign == 0)
  n_less    <- sum(pair_sign < 0)

  cles_observed <- (n_greater + 0.5 * n_ties) / n_pairs

  observed_cles_list[[i]] <- tibble(
    outcome        = outcome_col,
    label          = measures$label[i],
    adhd_n         = n_adhd,
    td_n           = n_td,
    n_pairs        = n_pairs,
    n_adhd_greater = n_greater,
    n_ties         = n_ties,
    n_adhd_less    = n_less,
    cles_observed  = cles_observed
  )

  cat(sprintf("%-12s: ADHD N = %d | TD N = %d | pairs = %d | observed CLES = %.3f\n",
              measures$label[i], n_adhd, n_td, n_pairs, cles_observed))
}

observed_cles <- bind_rows(observed_cles_list)

saveRDS(observed_cles, file.path(artifacts_dir, "observed_cles.rds"))

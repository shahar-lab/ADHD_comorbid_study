#### NON-PARAMETRIC CROSS-CHECK: MANN-WHITNEY CLES VS. BAYESIAN CLES ####
# reads: artifacts/df_full.rds, artifacts/posterior_effects.rds, artifacts/questionnaire_specs.rds
# writes: output/nonparametric_cles_crosscheck.csv

df_full             <- readRDS(file.path(artifacts_dir, "df_full.rds"))
posterior_effects   <- readRDS(file.path(artifacts_dir, "posterior_effects.rds"))
questionnaire_specs <- readRDS(file.path(artifacts_dir, "questionnaire_specs.rds"))

# Validate wilcox.test()'s W statistic against a direct pairwise-comparison sum
# for one questionnaire (AQ), confirming W / (n_ADHD * n_TD) equals the
# Mann-Whitney CLES formula before relying on it for all 10 questionnaires.
aq_adhd <- df_full |> filter(!is.na(aq), group_declared == "ADHD") |> pull(aq)
aq_td   <- df_full |> filter(!is.na(aq), group_declared == "TD") |> pull(aq)
direct_pairwise_cles <- sum(outer(aq_adhd, aq_td, function(a, t) (a > t) + 0.5 * (a == t))) / (length(aq_adhd) * length(aq_td))
wilcox_derived_cles   <- as.numeric(wilcox.test(x = aq_adhd, y = aq_td, exact = FALSE)$statistic) / (length(aq_adhd) * length(aq_td))
cat("AQ validation - direct pairwise CLES:", round(direct_pairwise_cles, 4),
    "vs. wilcox.test-derived CLES:", round(wilcox_derived_cles, 4), "\n")

crosscheck_rows <- list()

for (i in seq_len(nrow(questionnaire_specs))) {
  q_name <- questionnaire_specs$questionnaire[i]
  df_q   <- df_full |> filter(!is.na(.data[[q_name]]))

  scores_adhd <- df_q[[q_name]][df_q$group_declared == "ADHD"]
  scores_td   <- df_q[[q_name]][df_q$group_declared == "TD"]

  # x = ADHD, y = TD, so the W statistic directly counts I(adhd_i > td_j) +
  # 0.5 * I(adhd_i == td_j) pairs, matching the CLES_MW formula in the spec.
  wilcox_fit <- wilcox.test(x = scores_adhd, y = scores_td, exact = FALSE)
  cles_mw    <- as.numeric(wilcox_fit$statistic) / (length(scores_adhd) * length(scores_td))

  crosscheck_rows[[q_name]] <- tibble(
    Measure = questionnaire_specs$label[i],
    N_ADHD = length(scores_adhd),
    N_TD = length(scores_td),
    CLES_mann_whitney = round(cles_mw, 3),
    CLES_bayesian_median = round(median(posterior_effects[[q_name]]$cles), 3)
  )
}

nonparametric_cles_crosscheck <- bind_rows(crosscheck_rows)

write_csv(nonparametric_cles_crosscheck, file.path(output_dir, "nonparametric_cles_crosscheck.csv"))

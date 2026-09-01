#### SUMMARIZE POSTERIOR EFFECTS INTO THE MAIN CLES TABLE ####
# reads: artifacts/posterior_effects.rds, artifacts/questionnaire_specs.rds, artifacts/df_full.rds
# writes: output/cles_summary_table.csv, output/cles_summary_table.md, output/sample_sizes.csv

posterior_effects   <- readRDS(file.path(artifacts_dir, "posterior_effects.rds"))
questionnaire_specs <- readRDS(file.path(artifacts_dir, "questionnaire_specs.rds"))
df_full             <- readRDS(file.path(artifacts_dir, "df_full.rds"))

summary_rows     <- list()
sample_size_rows <- list()

for (i in seq_len(nrow(questionnaire_specs))) {
  q_name <- questionnaire_specs$questionnaire[i]
  eff    <- posterior_effects[[q_name]]

  df_q   <- df_full |> filter(!is.na(.data[[q_name]]))
  n_adhd <- sum(df_q$group_declared == "ADHD")
  n_td   <- sum(df_q$group_declared == "TD")

  diff_ci <- sprintf("%.2f [%.2f, %.2f]", median(eff$diff), quantile(eff$diff, .05), quantile(eff$diff, .95))
  d_ci    <- sprintf("%.2f [%.2f, %.2f]", median(eff$cohens_d), quantile(eff$cohens_d, .05), quantile(eff$cohens_d, .95))
  cles_ci <- sprintf("%.3f [%.3f, %.3f]", median(eff$cles), quantile(eff$cles, .05), quantile(eff$cles, .95))
  odds_ci <- sprintf("%.3f [%.3f, %.3f]", median(eff$odds), quantile(eff$odds, .05), quantile(eff$odds, .95))

  # PATAS and ICAR have no established literature cutoff (cutoff = NA in
  # questionnaire_specs) - risk ratio left blank for those two, per spec.
  # Same format as the difference/Cohen's d columns (2 decimals), per spec.
  rr_ci <- if (!is.na(questionnaire_specs$cutoff[i])) {
    sprintf("%.2f [%.2f, %.2f]", median(eff$rr), quantile(eff$rr, .05), quantile(eff$rr, .95))
  } else {
    NA
  }

  summary_rows[[q_name]] <- tibble(
    Domain = questionnaire_specs$domain[i],
    Measure = questionnaire_specs$label[i],
    `Posterior Difference (CrI)` = diff_ci,
    `Cohen's d (Median [CrI])` = d_ci,
    `CLES / P(X_ADHD > X_non) (Median [CrI])` = cles_ci,
    `Common Language Odds (Median [CrI])` = odds_ci,
    `Clinical Cutoff Risk Ratio (Median [CrI])` = rr_ci
  )

  # ASSUMED[N per questionnaire/group not specified as a main-table column]:
  # reported separately in a supplementary sample-size table, mirroring
  # analysis/auc's roc_sample_sizes.csv precedent.
  sample_size_rows[[q_name]] <- tibble(
    Measure = questionnaire_specs$label[i], N = nrow(df_q), N_ADHD = n_adhd, N_TD = n_td
  )
}

cles_summary_table <- bind_rows(summary_rows)
sample_sizes       <- bind_rows(sample_size_rows)

write_csv(cles_summary_table, file.path(output_dir, "cles_summary_table.csv"))
write_csv(sample_sizes, file.path(output_dir, "sample_sizes.csv"))
writeLines(kable(cles_summary_table, format = "markdown"), file.path(output_dir, "cles_summary_table.md"))

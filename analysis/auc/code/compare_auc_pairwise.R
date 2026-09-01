#### PAIRWISE DELONG AUC COMPARISONS ON COMMON-CASE SUBSAMPLES ####
# reads: artifacts/df_full.rds, artifacts/roc_stats.rds · writes: output/pairwise_auc_comparisons.csv

df_full   <- readRDS(file.path(artifacts_dir, "df_full.rds"))
roc_stats <- readRDS(file.path(artifacts_dir, "roc_stats.rds"))

# ASSUMED[no criterion given]: each questionnaire's direction is fixed to the value
# found in the full-sample fit (fit_roc_curves.R) - "<" for the 9 symptom measures,
# and whichever direction pROC's "auto" found for ICAR - and reused for every
# pairwise common-case refit, rather than re-running "auto" on each smaller
# subsample. This keeps ICAR's discrimination direction consistent across all
# comparisons instead of letting it flip on small/skewed subsamples.
directions <- setNames(roc_stats$direction_used, roc_stats$questionnaire)

pairs <- combn(roc_stats$questionnaire, 2, simplify = FALSE)

pairwise_rows <- list()
for (i in seq_along(pairs)) {
  q1 <- pairs[[i]][1]
  q2 <- pairs[[i]][2]

  df_common <- df_full |> filter(!is.na(.data[[q1]]), !is.na(.data[[q2]]))
  n_common  <- nrow(df_common)

  roc_1 <- roc(response = df_common$group_declared, predictor = df_common[[q1]],
               levels = c("TD", "ADHD"), direction = directions[[q1]], quiet = TRUE)
  roc_2 <- roc(response = df_common$group_declared, predictor = df_common[[q2]],
               levels = c("TD", "ADHD"), direction = directions[[q2]], quiet = TRUE)

  test_result <- roc.test(roc_1, roc_2, method = "delong", paired = TRUE)

  pairwise_rows[[i]] <- tibble(
    questionnaire_1 = q1, questionnaire_2 = q2, n_common = n_common,
    auc_1 = as.numeric(auc(roc_1)), auc_2 = as.numeric(auc(roc_2)),
    auc_diff = as.numeric(auc(roc_1)) - as.numeric(auc(roc_2)),
    p_raw = test_result$p.value
  )
}

pairwise_auc_comparisons <- bind_rows(pairwise_rows) |>
  mutate(p_holm = p.adjust(p_raw, method = "holm"),
         significant_holm_p05 = p_holm < .05) |>
  left_join(roc_stats |> select(questionnaire, label), by = c("questionnaire_1" = "questionnaire")) |>
  rename(questionnaire_1_label = label) |>
  left_join(roc_stats |> select(questionnaire, label), by = c("questionnaire_2" = "questionnaire")) |>
  rename(questionnaire_2_label = label) |>
  select(questionnaire_1_label, questionnaire_2_label, n_common, auc_1, auc_2,
         auc_diff, p_raw, p_holm, significant_holm_p05)

write_csv(pairwise_auc_comparisons, file.path(output_dir, "pairwise_auc_comparisons.csv"))
saveRDS(pairwise_auc_comparisons, file.path(artifacts_dir, "pairwise_auc_comparisons.rds"))

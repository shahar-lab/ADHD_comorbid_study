#### PREP DATA FOR REGRESSION ####
# reads: data/processed_data/df_remove_diagnosis_contradiction.Rdata · writes: artifacts/df_regression.rds

load(file.path(data_path, "df_remove_diagnosis_contradiction.Rdata"))

# group_declared already contains only ADHD/TD values in this file (per
# project convention - no extra filtering needed). TD is set as the reference
# level so the model Intercept is the TD mean and the group_declared
# coefficient is ADHD - TD, already on the raw patas_sum scale.
df <- df_remove_diagnosis_contradiction |>
  mutate(group_declared = factor(group_declared, levels = c("ADHD", "TD")),
         group_declared = relevel(group_declared, ref = "TD")) |>
  select(subjectid, group_declared, patas_sum) |>
  # Per specification: rows with missing patas_sum dropped. This
  # measure has far fewer non-missing values than the other measures in this
  # dataset (~194 of 465 subjects), so the resulting regression sample is
  # noticeably smaller, and the posterior/CI correspondingly wider, than in
  # the aq/bdi/ocir analyses - expected given the data, not a bug.
  filter(!is.na(patas_sum))

cat("Rows in regression sample (ADHD/TD, non-missing patas_sum):", nrow(df), "\n")
cat("Group counts:\n")
print(table(df$group_declared))

saveRDS(df, file.path(artifacts_dir, "df_regression.rds"))

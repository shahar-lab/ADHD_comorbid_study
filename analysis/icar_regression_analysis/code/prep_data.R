#### PREP DATA FOR REGRESSION ####
# reads: data/processed_data/df_remove_diagnosis_contradiction.Rdata · writes: artifacts/df_regression.rds

load(file.path(data_path, "df_remove_diagnosis_contradiction.Rdata"))

# group_declared already contains only ADHD/TD values in this file (per
# project convention - no extra filtering needed). TD is set as the reference
# level so the model Intercept is the TD mean and the group_declared
# coefficient is ADHD - TD, already on the raw icar scale.
df <- df_remove_diagnosis_contradiction |>
  mutate(group_declared = factor(group_declared, levels = c("ADHD", "TD")),
         group_declared = relevel(group_declared, ref = "TD")) |>
  select(subjectid, group_declared, icar) |>
  # Per spec: drop rows with missing icar
  filter(!is.na(icar))

cat("Rows in regression sample (ADHD/TD, non-missing icar):", nrow(df), "\n")
cat("Group counts:\n")
print(table(df$group_declared))

saveRDS(df, file.path(artifacts_dir, "df_regression.rds"))

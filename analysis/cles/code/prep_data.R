#### PREP DATA FOR CLES ANALYSIS ####
# reads: data/processed_data/df_remove_diagnosis_contradiction.Rdata · writes: artifacts/df_full.rds

load(file.path(data_path, "df_remove_diagnosis_contradiction.Rdata"))

# group_declared already contains only ADHD/TD values in this file (per project
# convention - no extra filtering needed). TD is set as the reference level so
# every model's Intercept is the TD mean (and TD log-sigma) and the
# group_declared coefficient is ADHD - TD. Complete-case filtering per
# questionnaire happens downstream in fit_models.R, since each of the 10
# questionnaires has its own missingness pattern (PATAS in particular).
df <- df_remove_diagnosis_contradiction |>
  mutate(group_declared = factor(group_declared, levels = c("ADHD", "TD")),
         group_declared = relevel(group_declared, ref = "TD")) |>
  select(subjectid, group_declared,
         aq, asrs, wurs, bdi, ocir, pqb, stai_state, stai_trait, patas_sum, icar) |>
  filter(!is.na(group_declared))

cat("Rows with non-missing group_declared:", nrow(df), "\n")
cat("Group counts:\n")
print(table(df$group_declared))

saveRDS(df, file.path(artifacts_dir, "df_full.rds"))

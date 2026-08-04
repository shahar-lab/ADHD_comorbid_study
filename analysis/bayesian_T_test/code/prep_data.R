#### PREP DATA ####

load(file.path(data_path, "df_remove_diagnosis_contradiction.Rdata"))

# Note: the group variable in the canonical processed data is `group_declared`
# (not `declared_group`). Only ADHD/TD are kept; any other value is dropped.
# Same convention as analysis/trial_analysis/code/prep_data.R.
df <- df_remove_diagnosis_contradiction |>
  filter(group_declared %in% c("ADHD", "TD")) |>
  mutate(group_declared = factor(group_declared, levels = c("ADHD", "TD"))) |>
  select(subjectid, group_declared, aq) |>
  drop_na(aq)

cat("Rows (ADHD/TD, non-missing AQ):", nrow(df), "\n")
print(table(df$group_declared))

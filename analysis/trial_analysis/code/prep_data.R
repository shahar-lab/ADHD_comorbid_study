#### PREP DATA ####

load(file.path(data_path, "df_remove_diagnosis_contradiction.Rdata"))

# Note: the group variable in the canonical processed data is `group_declared`
# (not `declared_group`). Only ADHD/TD are kept; any other value is dropped.
df <- df_remove_diagnosis_contradiction |>
  filter(group_declared %in% c("ADHD", "TD")) |>
  mutate(group_declared = factor(group_declared, levels = c("ADHD", "TD"))) |>
  select(subjectid, group_declared, bdi, aq, ocir, stai_trait, stai_state, icar)

# Data-quality check: missingness per measure, by group. Note: plain `stai`
# and `patas_sum`/`pqb` are intentionally excluded from this analysis folder.
missing_report <- df |>
  pivot_longer(cols = c(bdi, aq, ocir, stai_trait, stai_state, icar),
               names_to = "measure", values_to = "value") |>
  group_by(measure, group_declared) |>
  summarise(n_total = n(), n_missing = sum(is.na(value)), .groups = "drop")

cat("Rows plotted (ADHD/TD only):", nrow(df), "\n")
print(missing_report)

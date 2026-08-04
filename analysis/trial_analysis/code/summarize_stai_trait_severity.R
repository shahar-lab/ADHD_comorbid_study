#### SUMMARIZE STAI-TRAIT SEVERITY ####

# Counts/proportions computed on the raw STAI-Trait score, broken down by
# group_declared, plus an Overall row across both groups.
severity_by_group <- df_stai_trait_severity |>
  mutate(group_declared = as.character(group_declared)) |>
  count(group_declared, stai_trait_severity, name = "n") |>
  group_by(group_declared) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  ungroup()

severity_overall <- df_stai_trait_severity |>
  count(stai_trait_severity, name = "n") |>
  mutate(pct = round(100 * n / sum(n), 1), group_declared = "Overall")

severity_summary <- bind_rows(severity_by_group, severity_overall) |>
  rename(group = group_declared) |>
  select(group, stai_trait_severity, n, pct) |>
  arrange(match(group, c("ADHD", "TD", "Overall")), stai_trait_severity)

write_csv(severity_summary, file.path(output_dir, "stai_trait_severity_summary.csv"))

# Descriptive mean/SD per group, raw scale only (no transform for this measure).
descriptives_summary <- df_stai_trait_severity |>
  group_by(group_declared) |>
  summarise(
    n               = n(),
    mean_stai_trait = mean(stai_trait),
    sd_stai_trait   = sd(stai_trait),
    .groups = "drop"
  )

write_csv(descriptives_summary, file.path(output_dir, "stai_trait_descriptives_summary.csv"))

cat("STAI-Trait severity summary (by group + overall):\n")
print(severity_summary)
cat("\nSTAI-Trait descriptives (mean, SD) by group:\n")
print(descriptives_summary)

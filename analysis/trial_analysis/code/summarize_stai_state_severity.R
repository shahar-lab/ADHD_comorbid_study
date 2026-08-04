#### SUMMARIZE STAI-STATE SEVERITY ####

# Counts/proportions computed on the raw STAI-State score, broken down by
# group_declared, plus an Overall row across both groups.
severity_by_group <- df_stai_state_severity |>
  mutate(group_declared = as.character(group_declared)) |>
  count(group_declared, stai_state_severity, name = "n") |>
  group_by(group_declared) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  ungroup()

severity_overall <- df_stai_state_severity |>
  count(stai_state_severity, name = "n") |>
  mutate(pct = round(100 * n / sum(n), 1), group_declared = "Overall")

severity_summary <- bind_rows(severity_by_group, severity_overall) |>
  rename(group = group_declared) |>
  select(group, stai_state_severity, n, pct) |>
  arrange(match(group, c("ADHD", "TD", "Overall")), stai_state_severity)

write_csv(severity_summary, file.path(output_dir, "stai_state_severity_summary.csv"))

# Descriptive mean/SD per group, raw scale only (no transform for this measure).
descriptives_summary <- df_stai_state_severity |>
  group_by(group_declared) |>
  summarise(
    n               = n(),
    mean_stai_state = mean(stai_state),
    sd_stai_state   = sd(stai_state),
    .groups = "drop"
  )

write_csv(descriptives_summary, file.path(output_dir, "stai_state_descriptives_summary.csv"))

cat("STAI-State severity summary (by group + overall):\n")
print(severity_summary)
cat("\nSTAI-State descriptives (mean, SD) by group:\n")
print(descriptives_summary)

#### SUMMARIZE AQ SEVERITY ####

# Counts/proportions computed on the raw AQ score, broken down by
# group_declared, plus an Overall row across both groups.
severity_by_group <- df_aq_severity |>
  mutate(group_declared = as.character(group_declared)) |>
  count(group_declared, aq_severity, name = "n") |>
  group_by(group_declared) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  ungroup()

severity_overall <- df_aq_severity |>
  count(aq_severity, name = "n") |>
  mutate(pct = round(100 * n / sum(n), 1), group_declared = "Overall")

severity_summary <- bind_rows(severity_by_group, severity_overall) |>
  rename(group = group_declared) |>
  select(group, aq_severity, n, pct) |>
  arrange(match(group, c("ADHD", "TD", "Overall")), aq_severity)

write_csv(severity_summary, file.path(output_dir, "aq_severity_summary.csv"))

# Descriptive mean/SD per group, raw scale only (no transform for this measure).
descriptives_summary <- df_aq_severity |>
  group_by(group_declared) |>
  summarise(
    n       = n(),
    mean_aq = mean(aq),
    sd_aq   = sd(aq),
    .groups = "drop"
  )

write_csv(descriptives_summary, file.path(output_dir, "aq_descriptives_summary.csv"))

cat("AQ severity summary (by group + overall):\n")
print(severity_summary)
cat("\nAQ descriptives (mean, SD) by group:\n")
print(descriptives_summary)

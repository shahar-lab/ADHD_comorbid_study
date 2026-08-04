#### SUMMARIZE OCI-R SEVERITY ####

# Counts/proportions computed on the raw OCI-R score, broken down by
# group_declared, plus an Overall row across both groups.
severity_by_group <- df_ocir_severity |>
  mutate(group_declared = as.character(group_declared)) |>
  count(group_declared, ocir_severity, name = "n") |>
  group_by(group_declared) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  ungroup()

severity_overall <- df_ocir_severity |>
  count(ocir_severity, name = "n") |>
  mutate(pct = round(100 * n / sum(n), 1), group_declared = "Overall")

severity_summary <- bind_rows(severity_by_group, severity_overall) |>
  rename(group = group_declared) |>
  select(group, ocir_severity, n, pct) |>
  arrange(match(group, c("ADHD", "TD", "Overall")), ocir_severity)

write_csv(severity_summary, file.path(output_dir, "ocir_severity_summary.csv"))

# Descriptive mean/SD per group, raw scale only (no transform for this measure).
descriptives_summary <- df_ocir_severity |>
  group_by(group_declared) |>
  summarise(
    n         = n(),
    mean_ocir = mean(ocir),
    sd_ocir   = sd(ocir),
    .groups = "drop"
  )

write_csv(descriptives_summary, file.path(output_dir, "ocir_descriptives_summary.csv"))

cat("OCI-R severity summary (by group + overall):\n")
print(severity_summary)
cat("\nOCI-R descriptives (mean, SD) by group:\n")
print(descriptives_summary)

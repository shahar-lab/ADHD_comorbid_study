#### SUMMARIZE BDI SEVERITY ####

# Severity counts/proportions computed on the ORIGINAL 0-63 BDI score, broken
# down by group_declared, plus an Overall row across both groups.
severity_by_group <- df_bdi_severity |>
  mutate(group_declared = as.character(group_declared)) |>
  count(group_declared, bdi_severity, name = "n") |>
  group_by(group_declared) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  ungroup()

severity_overall <- df_bdi_severity |>
  count(bdi_severity, name = "n") |>
  mutate(pct = round(100 * n / sum(n), 1), group_declared = "Overall")

severity_summary <- bind_rows(severity_by_group, severity_overall) |>
  rename(group = group_declared) |>
  select(group, bdi_severity, n, pct) |>
  arrange(match(group, c("ADHD", "TD", "Overall")), bdi_severity)

write_csv(severity_summary, file.path(output_dir, "bdi_severity_summary.csv"))

# Descriptive mean/SD per group, both scales (feeds the figure annotations).
descriptives_summary <- df_bdi_severity |>
  group_by(group_declared) |>
  summarise(
    n                    = n(),
    mean_bdi_raw         = mean(bdi),
    sd_bdi_raw           = sd(bdi),
    mean_bdi_transformed = mean(bdi_transformed),
    sd_bdi_transformed   = sd(bdi_transformed),
    .groups = "drop"
  )

write_csv(descriptives_summary, file.path(output_dir, "bdi_descriptives_summary.csv"))

cat("BDI severity summary (by group + overall):\n")
print(severity_summary)
cat("\nBDI descriptives (mean, SD) by group:\n")
print(descriptives_summary)

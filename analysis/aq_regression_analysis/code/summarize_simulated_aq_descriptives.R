#### SUMMARIZE SIMULATED AQ: OVERVIEW, DESCRIPTIVES, SKEW/KURTOSIS, OUTLIERS ####
# reads: artifacts/simulated_aq_from_posterior.csv · writes: output/simulated_aq_descriptives_summary.csv, output/simulated_aq_skew_kurtosis_summary.csv, output/simulated_aq_outliers.csv

df_sim <- read_csv(file.path(artifacts_dir, "simulated_aq_from_posterior.csv"), show_col_types = FALSE)

# Dataset overview
n_total <- nrow(df_sim)
n_adhd  <- sum(df_sim$group == "ADHD")
n_td    <- sum(df_sim$group == "TD")

# Group coding is checked and reported explicitly, then enforced, rather than
# a bare silent stopifnot() - mirrors simulate_aq_from_posterior.R's pattern.
coding_ok <- all(df_sim$group_declaredADHD[df_sim$group == "ADHD"] == 1) &&
             all(df_sim$group_declaredADHD[df_sim$group == "TD"] == 0)
cat("Group coding check (TD = 0 / ADHD = 1) passed:", coding_ok, "\n")
stopifnot(coding_ok)

n_missing       <- sum(is.na(df_sim$AQ))
n_dup_id        <- sum(duplicated(df_sim$participant_id))
aq_out_of_range <- df_sim |> filter(AQ < 0 | AQ > 50)

cat("Total N:", n_total, "| ADHD N:", n_adhd, "| TD N:", n_td, "\n")
cat("Missing AQ values:", n_missing, "| Duplicate participant_ids:", n_dup_id, "\n")
cat("AQ range: [", min(df_sim$AQ), ",", max(df_sim$AQ), "]\n")
cat("AQ values outside [0, 50]:", nrow(aq_out_of_range), "\n")
if (nrow(aq_out_of_range) > 0) print(aq_out_of_range |> select(participant_id, group, AQ))

# Descriptive statistics, by group and overall
descriptives_by_group <- df_sim |>
  group_by(group) |>
  summarise(n = n(), mean = mean(AQ), sd = sd(AQ), median = median(AQ),
            min = min(AQ), max = max(AQ), q1 = quantile(AQ, 0.25), q3 = quantile(AQ, 0.75),
            iqr = q3 - q1, .groups = "drop")

descriptives_overall <- df_sim |>
  summarise(n = n(), mean = mean(AQ), sd = sd(AQ), median = median(AQ),
            min = min(AQ), max = max(AQ), q1 = quantile(AQ, 0.25), q3 = quantile(AQ, 0.75),
            iqr = q3 - q1) |>
  mutate(group = "Overall")

descriptives_summary <- bind_rows(descriptives_by_group, descriptives_overall) |>
  select(group, n, mean, sd, median, min, max, q1, q3, iqr)

cat("\nDescriptive statistics by group and overall:\n")
print(descriptives_summary)
write_csv(descriptives_summary, file.path(output_dir, "simulated_aq_descriptives_summary.csv"))

# Skewness and kurtosis
# ASSUMED[no formula/package specified]: sample skewness (Fisher-Pearson
# moment coefficient, uncorrected) and excess kurtosis, computed directly
# from central moments rather than pulling in an extra package.
skew_kurt_by_group <- df_sim |>
  group_by(group) |>
  summarise(skewness = mean((AQ - mean(AQ))^3) / mean((AQ - mean(AQ))^2)^1.5,
            kurtosis_excess = mean((AQ - mean(AQ))^4) / mean((AQ - mean(AQ))^2)^2 - 3,
            .groups = "drop")

skew_kurt_overall <- df_sim |>
  summarise(skewness = mean((AQ - mean(AQ))^3) / mean((AQ - mean(AQ))^2)^1.5,
            kurtosis_excess = mean((AQ - mean(AQ))^4) / mean((AQ - mean(AQ))^2)^2 - 3) |>
  mutate(group = "Overall")

skew_kurtosis_summary <- bind_rows(skew_kurt_by_group, skew_kurt_overall) |>
  select(group, skewness, kurtosis_excess)

cat("\nSkewness / excess kurtosis by group and overall:\n")
print(skew_kurtosis_summary)
write_csv(skew_kurtosis_summary, file.path(output_dir, "simulated_aq_skew_kurtosis_summary.csv"))

# Outliers (1.5 x IQR rule)
outliers <- df_sim |>
  group_by(group) |>
  mutate(q1 = quantile(AQ, 0.25), q3 = quantile(AQ, 0.75), iqr = q3 - q1,
         lower_fence = q1 - 1.5 * iqr, upper_fence = q3 + 1.5 * iqr) |>
  ungroup() |>
  filter(AQ < lower_fence | AQ > upper_fence) |>
  select(participant_id, group, AQ)

cat("\nOutliers (1.5xIQR rule) per group:\n")
print(outliers |> count(group, name = "n_outliers"))
print(outliers)
write_csv(outliers, file.path(output_dir, "simulated_aq_outliers.csv"))

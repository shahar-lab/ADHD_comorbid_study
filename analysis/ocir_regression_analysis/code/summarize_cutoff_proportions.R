#### SUMMARIZE PANEL D: CLINICAL CUTOFF PROPORTION TABLE ####
# reads: artifacts/model_fit.rds, artifacts/posterior_draws.rds · writes: output/cutoff_proportion_summary.csv

model_fit       <- readRDS(file.path(artifacts_dir, "model_fit.rds"))
posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))

cutoff_raw <- 21

# Same sigma draws, paired index-for-index with posterior_draws$td / $adhd,
# as plot_panel_d.R.
sigma_draws <- as_draws_df(model_fit)$sigma

prop_above_td   <- 1 - pnorm(cutoff_raw, mean = posterior_draws$td,   sd = sigma_draws)
prop_above_adhd <- 1 - pnorm(cutoff_raw, mean = posterior_draws$adhd, sd = sigma_draws)

cutoff_summary <- tibble(
  group  = c("without ADHD", "with ADHD"),
  median = c(median(prop_above_td), median(prop_above_adhd)),
  ci_90_lower = c(quantile(prop_above_td, 0.05), quantile(prop_above_adhd, 0.05)),
  ci_90_upper = c(quantile(prop_above_td, 0.95), quantile(prop_above_adhd, 0.95))
) |>
  mutate(across(where(is.numeric), ~round(.x, 3))) |>
  rename(
    "Group"                       = group,
    "Median proportion above cutoff" = median,
    "90% CI lower"                = ci_90_lower,
    "90% CI upper"                = ci_90_upper
  )

print(cutoff_summary)

write_csv(cutoff_summary, file.path(output_dir, "cutoff_proportion_summary.csv"))

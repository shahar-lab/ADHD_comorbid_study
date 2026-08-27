#### SUMMARIZE CUTOFF PROPORTIONS: POSTERIOR SUMMARY TABLE ####
# reads: artifacts/model_fit.rds, artifacts/posterior_draws.rds · writes: output/cutoff_proportion_summary.csv

model_fit       <- readRDS(file.path(artifacts_dir, "model_fit.rds"))
posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))

group_labels <- c(TD = "without ADHD", ADHD = "with ADHD")
cutoff_raw   <- 14

# Same posterior-draw pairing as plot_panel_d.R
sigma_draws <- as_draws_df(model_fit)$sigma

prop_above_td   <- 1 - pnorm(cutoff_raw, mean = posterior_draws$td, sd = sigma_draws)
prop_above_adhd <- 1 - pnorm(cutoff_raw, mean = posterior_draws$adhd, sd = sigma_draws)

cutoff_summary <- tibble(
  Group = c(group_labels["TD"], group_labels["ADHD"]),
  `Median proportion above cutoff` = round(c(median(prop_above_td), median(prop_above_adhd)), 3),
  `Lower 90% CI` = round(c(quantile(prop_above_td, 0.05), quantile(prop_above_adhd, 0.05)), 3),
  `Upper 90% CI` = round(c(quantile(prop_above_td, 0.95), quantile(prop_above_adhd, 0.95)), 3)
)

print(cutoff_summary)

write_csv(cutoff_summary, file.path(output_dir, "cutoff_proportion_summary.csv"))

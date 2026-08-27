#### SUMMARIZE CUTOFF PROPORTIONS: MEDIAN + 90% CI BY GROUP ####
# reads: artifacts/model_fit.rds, artifacts/posterior_draws.rds · writes: output/cutoff_proportion_summary.csv

model_fit       <- readRDS(file.path(artifacts_dir, "model_fit.rds"))
posterior_draws <- readRDS(file.path(artifacts_dir, "posterior_draws.rds"))

group_labels <- c(TD = "without ADHD", ADHD = "with ADHD")
cutoff_raw   <- 44

# Same posterior-draw-index pairing as plot_panel_d.R: sigma_draws is drawn
# from as_draws_df's default order, matching posterior_draws$td / $adhd's
# posterior_epred draw order, so each sigma draw pairs with the group-mean
# draw from the same posterior sample.
sigma_draws <- as_draws_df(model_fit)$sigma

prop_above_td   <- 1 - pnorm(cutoff_raw, mean = posterior_draws$td,   sd = sigma_draws)
prop_above_adhd <- 1 - pnorm(cutoff_raw, mean = posterior_draws$adhd, sd = sigma_draws)

cutoff_proportion_summary <- tibble(
  group  = c("TD", "ADHD"),
  median_proportion = c(median(prop_above_td), median(prop_above_adhd)),
  lower90 = c(quantile(prop_above_td, 0.05), quantile(prop_above_adhd, 0.05)),
  upper90 = c(quantile(prop_above_td, 0.95), quantile(prop_above_adhd, 0.95))
) |>
  mutate(group = group_labels[group]) |>
  rename(`Group` = group,
         `Median proportion above cutoff` = median_proportion,
         `Lower 90% CI` = lower90,
         `Upper 90% CI` = upper90) |>
  mutate(across(where(is.numeric), \(x) round(x, 3)))

print(cutoff_proportion_summary)
write_csv(cutoff_proportion_summary, file.path(output_dir, "cutoff_proportion_summary.csv"))

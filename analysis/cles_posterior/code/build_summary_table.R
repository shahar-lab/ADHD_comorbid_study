#### BUILD CLES COMPARISON SUMMARY TABLE ####
# reads: artifacts/posterior_cles_draws.rds, artifacts/observed_cles.rds
# writes: output/cles_posterior_draws.csv, output/cles_summary.csv

posterior_cles_draws <- readRDS(file.path(artifacts_dir, "posterior_cles_draws.rds"))
observed_cles        <- readRDS(file.path(artifacts_dir, "observed_cles.rds"))

posterior_summary <- posterior_cles_draws |>
  group_by(outcome) |>
  summarise(
    n_draws          = n(),
    posterior_median = median(CLES),
    posterior_mean   = mean(CLES),
    posterior_sd     = sd(CLES),
    ci_lower         = unname(quantile(CLES, 0.025)),
    ci_upper         = unname(quantile(CLES, 0.975)),
    p_gt_half        = mean(CLES > 0.50),
    .groups = "drop"
  )

cles_summary <- observed_cles |>
  left_join(posterior_summary, by = "outcome") |>
  transmute(
    outcome,
    Measure                 = label,
    `ADHD N`                = adhd_n,
    `TD N`                  = td_n,
    `Observed CLES`         = cles_observed,
    `Posterior Median CLES` = posterior_median,
    `Posterior Mean CLES`   = posterior_mean,
    `Posterior SD CLES`     = posterior_sd,
    `95% CrI Lower`         = ci_lower,
    `95% CrI Upper`         = ci_upper,
    `P(CLES > 0.50)`        = p_gt_half,
    `Posterior Draws Used`  = n_draws
  )

# Full console report -- printed before any output file (CSV/plot) is written.
cat("\n==== CLES SUMMARY REPORT ====\n")
cat("Outcomes analyzed:", nrow(cles_summary), "\n")
cat("Posterior draws used per outcome (all 9 should read 4000):\n")
print(setNames(cles_summary$`Posterior Draws Used`, cles_summary$Measure))

for (i in seq_len(nrow(cles_summary))) {
  row <- cles_summary[i, ]
  cat(sprintf(
    "\n%s: ADHD N = %d, TD N = %d\n  Observed CLES = %.3f\n  Posterior median CLES = %.3f [95%% CrI: %.3f-%.3f]\n  P(CLES > 0.50) = %.3f\n",
    row$Measure, row$`ADHD N`, row$`TD N`, row$`Observed CLES`,
    row$`Posterior Median CLES`, row$`95% CrI Lower`, row$`95% CrI Upper`, row$`P(CLES > 0.50)`
  ))
}

# Sanity checks -- per outcome and overall.
sanity_by_outcome <- posterior_cles_draws |>
  group_by(outcome) |>
  summarise(posterior_range_ok = all(CLES >= 0 & CLES <= 1), .groups = "drop") |>
  left_join(cles_summary |> select(outcome, Measure, `95% CrI Lower`, `95% CrI Upper`,
                                    `P(CLES > 0.50)`, `Observed CLES`), by = "outcome") |>
  left_join(observed_cles |> select(outcome, n_pairs, adhd_n, td_n), by = "outcome") |>
  mutate(
    ci_order_ok      = `95% CrI Lower` <= `95% CrI Upper`,
    p_range_ok       = `P(CLES > 0.50)` >= 0 & `P(CLES > 0.50)` <= 1,
    observed_range_ok = `Observed CLES` >= 0 & `Observed CLES` <= 1,
    pair_count_ok    = n_pairs == adhd_n * td_n,
    all_pass         = posterior_range_ok & ci_order_ok & p_range_ok & observed_range_ok & pair_count_ok
  )

cat("\n==== SANITY CHECKS (per outcome) ====\n")
print(sanity_by_outcome |>
        select(Measure, posterior_range_ok, ci_order_ok, p_range_ok, observed_range_ok, pair_count_ok, all_pass))

cat("\nOverall sanity check:", ifelse(all(sanity_by_outcome$all_pass), "PASS", "FAIL"), "\n")

write_csv(cles_summary |> select(-outcome), file.path(output_dir, "cles_summary.csv"))
write_csv(posterior_cles_draws, file.path(output_dir, "cles_posterior_draws.csv"))

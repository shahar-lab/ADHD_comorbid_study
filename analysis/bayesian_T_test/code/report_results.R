#### REPORT RESULTS ####

# Sign-convention sanity check (auditable from script output, not just a
# comment): confirm delta's sign matches the raw group-mean difference before
# trusting any directional claim below.
group_means <- df |>
  group_by(group_declared) |>
  summarise(mean_aq = mean(aq), .groups = "drop")

adhd_mean <- group_means$mean_aq[group_means$group_declared == "ADHD"]
td_mean   <- group_means$mean_aq[group_means$group_declared == "TD"]

empirical_sign <- sign(adhd_mean - td_mean)
delta_sign     <- sign(d_median)

cat("\n---- Sign-convention check ----\n")
cat(sprintf("Raw group means -- ADHD: %.2f, TD: %.2f (ADHD - TD = %.2f)\n", adhd_mean, td_mean, adhd_mean - td_mean))
cat(sprintf("Sign of raw ADHD - TD difference: %d | sign of posterior median delta: %d\n", empirical_sign, delta_sign))
if (empirical_sign == delta_sign) {
  cat("Sign check OK: delta's direction (ADHD - TD) matches the raw group-mean difference.\n")
} else {
  cat("WARNING: sign mismatch between raw group means and posterior delta -- do not trust the directional interpretation below without investigating.\n")
}

# Direction check: delta = "ADHD - TD" (BayesFactor::posterior() column
# convention, now confirmed above against raw group means, not just a
# comment). BF10 only tests whether the groups differ at all (two-sided); it
# carries no direction. Direction is read off the sign/CI of the posterior
# delta.
direction <- case_when(
  d_ci[1] > 0 ~ "ADHD scored reliably higher on AQ than TD",
  d_ci[2] < 0 ~ "TD scored reliably higher on AQ than ADHD",
  TRUE        ~ "the 95% credible interval for delta spans zero, so directionality is not resolved"
)

cat("\n==================== RESULTS ====================\n")
cat(sprintf("BF10 (BayesFactor::ttestBF, default Cauchy prior, two-sided): %.3g\n", bf10))
cat(sprintf("BF01: %.3g\n", bf01))
cat(sprintf("Posterior median delta (BayesFactor::posterior, Cohen's d, ADHD - TD): %.3f\n", d_median))
cat(sprintf("95%% credible interval: [%.3f, %.3f]\n", d_ci[1], d_ci[2]))
cat("\nInterpretation:\n")
cat("BF10 tests only whether the two groups differ at all (two-sided, default\n")
cat("Cauchy prior, unrestricted alternative) -- it does not by itself indicate\n")
cat("which group is higher. Direction comes from the sign and 95% credible\n")
cat("interval of the posterior delta (BayesFactor::posterior()), not from BF10.\n")
cat(sprintf("Here: %s.\n", direction))
cat("===================================================\n")

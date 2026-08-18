#### SUMMARIZE SIMULATED AQ: GROUP DIFFERENCE, ASSUMPTION CHECKS, MODEL-IMPLIED COMPARISON ####
# reads: artifacts/simulated_aq_from_posterior.csv, artifacts/model_fit.rds · writes: output/simulated_aq_group_comparison_summary.csv

df_sim    <- read_csv(file.path(artifacts_dir, "simulated_aq_from_posterior.csv"), show_col_types = FALSE)
model_fit <- readRDS(file.path(artifacts_dir, "model_fit.rds"))

aq_adhd <- df_sim$AQ[df_sim$group == "ADHD"]
aq_td   <- df_sim$AQ[df_sim$group == "TD"]

mean_diff   <- mean(aq_adhd) - mean(aq_td)
median_diff <- median(aq_adhd) - median(aq_td)

shapiro_adhd <- shapiro.test(aq_adhd)
shapiro_td   <- shapiro.test(aq_td)
# Variance homogeneity checked with base R's var.test() (F test), per the
# specification's named options (Levene's test or var.test), avoiding an
# extra package.
var_test <- var.test(aq_adhd, aq_td)

cat("Shapiro-Wilk (ADHD): W =", round(shapiro_adhd$statistic, 3), "p =", round(shapiro_adhd$p.value, 4), "\n")
cat("Shapiro-Wilk (TD): W =", round(shapiro_td$statistic, 3), "p =", round(shapiro_td$p.value, 4), "\n")
cat("Variance homogeneity (var.test): F =", round(var_test$statistic, 3), "p =", round(var_test$p.value, 4), "\n")

# ASSUMED[no alpha given]: var.test p < .05 -> Welch (unequal variances);
# otherwise Student's t-test (equal variances, pooled SD). The mean-difference
# CI below (t.test's own conf.int) inherits this same decision.
equal_var <- var_test$p.value >= .05
t_result  <- t.test(aq_adhd, aq_td, var.equal = equal_var)
cat("\nIndependent-samples t-test (", ifelse(equal_var, "Student, equal variances", "Welch, unequal variances"), "):\n", sep = "")
cat("t =", round(t_result$statistic, 3), "| df =", round(t_result$parameter, 2),
    "| p =", format.pval(t_result$p.value, digits = 4),
    "| 95% CI mean diff = [", round(t_result$conf.int[1], 2), ",", round(t_result$conf.int[2], 2), "]\n")

# ASSUMED[method not specified beyond the example given]: Cohen's d (pooled
# SD) with a 95% CI computed via effsize::cohen.d() (noncentral-t interval).
d_result <- cohen.d(aq_adhd, aq_td, pooled = TRUE, conf.level = 0.95)
cat("Cohen's d =", round(d_result$estimate, 3),
    "| 95% CI = [", round(d_result$conf.int[1], 3), ",", round(d_result$conf.int[2], 3), "] (effsize::cohen.d)\n")

wilcox_result <- wilcox.test(aq_adhd, aq_td, conf.int = TRUE)
cat("\nWilcoxon/Mann-Whitney: W =", wilcox_result$statistic, "| p =", format.pval(wilcox_result$p.value, digits = 4), "\n")
cat("Note: if either Shapiro-Wilk test rejects normality (p < .05), the Wilcoxon test above is the\n",
    "more appropriate primary result; the t-test assumes normality within each group.\n", sep = "")

comparison_summary <- tibble(
  metric = c("mean_diff_ADHD_minus_TD", "median_diff_ADHD_minus_TD",
             "cohens_d", "cohens_d_ci_low", "cohens_d_ci_high",
             "mean_diff_ci_low", "mean_diff_ci_high",
             "t_statistic", "t_df", "t_pvalue", "t_test_type",
             "shapiro_W_ADHD", "shapiro_p_ADHD", "shapiro_W_TD", "shapiro_p_TD",
             "var_test_F", "var_test_p", "wilcoxon_W", "wilcoxon_p"),
  value = c(sprintf("%.3f", mean_diff), sprintf("%.3f", median_diff),
            sprintf("%.3f", d_result$estimate), sprintf("%.3f", d_result$conf.int[1]), sprintf("%.3f", d_result$conf.int[2]),
            sprintf("%.3f", t_result$conf.int[1]), sprintf("%.3f", t_result$conf.int[2]),
            sprintf("%.3f", t_result$statistic), sprintf("%.2f", t_result$parameter), format.pval(t_result$p.value, digits = 4),
            ifelse(equal_var, "Student", "Welch"),
            sprintf("%.3f", shapiro_adhd$statistic), format.pval(shapiro_adhd$p.value, digits = 4),
            sprintf("%.3f", shapiro_td$statistic), format.pval(shapiro_td$p.value, digits = 4),
            sprintf("%.3f", var_test$statistic), format.pval(var_test$p.value, digits = 4),
            sprintf("%.1f", wilcox_result$statistic), format.pval(wilcox_result$p.value, digits = 4))
)
write_csv(comparison_summary, file.path(output_dir, "simulated_aq_group_comparison_summary.csv"))

# Model-implied comparison (posterior medians pulled fresh from model_fit.rds)
draws           <- as_draws_df(model_fit)
b_intercept_med <- median(draws$b_Intercept)
b_slope_med     <- median(draws$b_group_declaredADHD)

model_implied <- tibble(
  group               = c("TD", "ADHD"),
  model_implied_mean  = c(b_intercept_med, b_intercept_med + b_slope_med),
  observed_mean       = c(mean(aq_td), mean(aq_adhd))
) |>
  mutate(diff = observed_mean - model_implied_mean)

model_implied_diff <- tibble(
  quantity      = c("model_implied (b_group_declaredADHD median)", "observed_simulated (ADHD - TD)"),
  adhd_minus_td = c(b_slope_med, mean_diff)
)

cat("\nModel-implied vs observed group means:\n")
print(model_implied)
cat("\nModel-implied ADHD - TD vs observed simulated ADHD - TD:\n")
print(model_implied_diff)

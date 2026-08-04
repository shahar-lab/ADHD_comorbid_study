#### BAYES FACTOR (BayesFactor::ttestBF) ####

# Default independent-samples JZS t-test: default Cauchy prior on effect size
# (rscale = "medium"), two-sided, unrestricted alternative (no nullInterval).
# This BF10/BF01 is the vehicle for the Bayes factor only; the effect-size
# posterior (delta + 95% CrI) is produced separately in fit_posterior_delta.R.
bf_object <- ttestBF(formula = aq ~ group_declared, data = as.data.frame(df))

bf10 <- extractBF(bf_object)$bf
bf01 <- 1 / bf10

saveRDS(bf_object, file.path(artifacts_dir, "bf_object.rds"))

cat("BF10 (ADHD vs TD differ in AQ, from BayesFactor::ttestBF):", bf10, "\n")
cat("BF01 (null over alternative):", bf01, "\n")

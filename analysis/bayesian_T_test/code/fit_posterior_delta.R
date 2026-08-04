#### POSTERIOR OF DELTA (BayesFactor::posterior) ####

# Draws from the same JZS model that produced BF10/BF01 above, so the
# effect-size posterior is fully consistent with the Bayes factor. Column
# convention: with group_declared levels c("ADHD", "TD"), BayesFactor labels
# the contrast "beta (ADHD - TD)" and delta follows the same direction, i.e.
# positive delta = higher AQ in ADHD (checked against raw group means in
# report_results.R, not just asserted here).
#
# Run as 4 independent chains (2500 iterations each = 10000 pooled draws,
# same total as before) rather than one long chain, so rhat/ess_bulk/ess_tail
# are defined for the mandatory diagnostics artifact (diagnostics.R).
n_chains <- 4
n_iter   <- 2500

posterior_chains <- lapply(seq_len(n_chains), function(i) posterior(bf_object, iterations = n_iter))
posterior_mcmc_list <- coda::mcmc.list(posterior_chains)
posterior_draws_array <- as_draws_array(posterior_mcmc_list)

delta_draws <- unlist(lapply(posterior_chains, function(ch) as.matrix(ch)[, "delta"]))

d_median <- median(delta_draws)
d_ci     <- quantile(delta_draws, probs = c(0.025, 0.975))

saveRDS(posterior_mcmc_list, file.path(artifacts_dir, "posterior_chains.rds"))
saveRDS(posterior_draws_array, file.path(artifacts_dir, "posterior_draws_array.rds"))
saveRDS(delta_draws, file.path(artifacts_dir, "delta_draws.rds"))

cat("Posterior median delta (Cohen's d, ADHD - TD, from BayesFactor::posterior,", n_chains, "chains x", n_iter, "iterations):", round(d_median, 3), "\n")
cat("95% credible interval:", round(d_ci[1], 3), "to", round(d_ci[2], 3), "\n")

#### EXTRACT POSTERIOR DRAWS FOR PLOTTING ####
# reads: artifacts/model_fit.rds · writes: artifacts/posterior_draws.rds

model_fit <- readRDS(file.path(artifacts_dir, "model_fit.rds"))

# Posterior expected-value draws (posterior_epred = mean of the outcome,
# excludes residual noise - not posterior_predict) for each group. Newdata
# factor levels match the model's training levels (TD reference, then ADHD).
newdata_groups <- tibble(group_declared = factor(c("TD", "ADHD"), levels = c("TD", "ADHD")))
epred_draws <- posterior_epred(model_fit, newdata = newdata_groups, summary = FALSE)

draws_td   <- epred_draws[, 1]
draws_adhd <- epred_draws[, 2]

# Effect posterior (ADHD - TD, raw ocir scale) - equivalent to the b_group
# coefficient's posterior in this simple identity-link, single-predictor model.
draws_diff <- draws_adhd - draws_td

# Ratio posterior (ADHD mean / TD mean); null/no-difference value is 1, not 0.
draws_ratio <- draws_adhd / draws_td

posterior_draws <- list(td = draws_td, adhd = draws_adhd, diff = draws_diff, ratio = draws_ratio)

saveRDS(posterior_draws, file.path(artifacts_dir, "posterior_draws.rds"))

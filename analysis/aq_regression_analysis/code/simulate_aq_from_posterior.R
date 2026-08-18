#### SIMULATE AQ FROM POSTERIOR DRAWS ####
# reads: artifacts/model_fit.rds · writes: artifacts/simulated_aq_from_posterior.csv

model_fit <- readRDS(file.path(artifacts_dir, "model_fit.rds"))

# Raw posterior draws (not summaries) for the three parameters the likelihood needs.
draws   <- as_draws_df(model_fit) |>
  select(b_Intercept, b_group_declaredADHD, sigma)
n_draws <- nrow(draws)

# Simulated participant set: 214 ADHD, 250 TD, fresh synthetic IDs (not reused
# from the real data).
n_adhd  <- 214
n_td    <- 250
n_total <- n_adhd + n_td

df_sim <- tibble(
  participant_id     = sprintf("sim_%03d", 1:n_total),
  group_declaredADHD = c(rep(1, n_adhd), rep(0, n_td)),
  group               = c(rep("ADHD", n_adhd), rep("TD", n_td))
)

# Each participant independently samples its own posterior draw (with
# replacement) and is simulated from that draw's own parameters, so the
# output carries both posterior parameter uncertainty and residual noise -
# not a single shared draw or the posterior median. AQ is not
# truncated, clipped, rounded, or rescaled: the model itself has no bound.
sampled_idx   <- sample(1:n_draws, size = n_total, replace = TRUE)
sampled_draws <- draws[sampled_idx, ]

df_sim <- df_sim |>
  mutate(
    sim_intercept = sampled_draws$b_Intercept,
    sim_slope     = sampled_draws$b_group_declaredADHD,
    sim_sigma     = sampled_draws$sigma,
    AQ            = rnorm(n_total,
                           mean = sim_intercept + sim_slope * group_declaredADHD,
                           sd   = sim_sigma)
  ) |>
  select(participant_id, group_declaredADHD, group, AQ)

# Verify N and group coding before saving.
stopifnot(nrow(df_sim) == 464)
stopifnot(sum(df_sim$group == "ADHD") == 214)
stopifnot(sum(df_sim$group == "TD") == 250)
stopifnot(all(df_sim$group_declaredADHD[df_sim$group == "ADHD"] == 1))
stopifnot(all(df_sim$group_declaredADHD[df_sim$group == "TD"] == 0))

cat("Total N:", nrow(df_sim), "\n")
cat("ADHD N:", sum(df_sim$group == "ADHD"), "\n")
cat("TD N:", sum(df_sim$group == "TD"), "\n")

# Posterior summary of the parameters actually used above (median, 90% CI).
# ASSUMED[no CI width given]: 90% credible interval reported.
param_summary <- tibble(
  parameter = c("b_Intercept", "b_group_declaredADHD", "sigma"),
  median = c(median(draws$b_Intercept), median(draws$b_group_declaredADHD), median(draws$sigma)),
  q05    = c(quantile(draws$b_Intercept, 0.05), quantile(draws$b_group_declaredADHD, 0.05), quantile(draws$sigma, 0.05)),
  q95    = c(quantile(draws$b_Intercept, 0.95), quantile(draws$b_group_declaredADHD, 0.95), quantile(draws$sigma, 0.95))
)
cat("Posterior parameter summary (median, 90% CI):\n")
print(param_summary)

group_summary <- df_sim |>
  group_by(group) |>
  summarise(mean = mean(AQ), sd = sd(AQ), min = min(AQ), max = max(AQ))
cat("Simulated AQ summary by group:\n")
print(group_summary)

write_csv(df_sim, file.path(artifacts_dir, "simulated_aq_from_posterior.csv"))

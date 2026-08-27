#### MODEL DIAGNOSTICS ####
# reads: artifacts/model_fit.rds · writes: output/diagnostic.pdf

model_fit <- readRDS(file.path(artifacts_dir, "model_fit.rds"))
draws     <- as_draws_array(model_fit)

summary_table <- summarise_draws(draws, ess_bulk, ess_tail, rhat)
summary_table[-1] <- round(summary_table[-1], 2)

trank_plot <- mcmc_rank_overlay(draws)
pairs_plot <- mcmc_pairs(draws)

pdf(file.path(output_dir, "diagnostic.pdf"), width = 8, height = 6)
grid.arrange(tableGrob(summary_table))
print(trank_plot)
print(pairs_plot)
dev.off()

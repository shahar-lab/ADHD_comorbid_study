#### MCMC DIAGNOSTICS ####

# Mandatory diagnostics artifact per bayesian-regression skill
# (references/02_diagnostics.md): summary table (rhat, ess_bulk, ess_tail),
# trankplot, pairs plot -- one diagnostic.pdf, saved to output/. Built from
# the 4-chain posterior_draws_array produced in fit_posterior_delta.R.
summary_table <- summarise_draws(posterior_draws_array, "rhat", "ess_bulk", "ess_tail")
summary_table[-1] <- round(summary_table[-1], 2)

trank_plot <- mcmc_rank_overlay(posterior_draws_array)
pairs_plot <- mcmc_pairs(posterior_draws_array)

pdf(file.path(output_dir, "diagnostic.pdf"), width = 8, height = 6)
gridExtra::grid.arrange(gridExtra::tableGrob(summary_table))
print(trank_plot)
print(pairs_plot)
dev.off()

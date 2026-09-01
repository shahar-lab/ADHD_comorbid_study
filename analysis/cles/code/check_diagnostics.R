#### MODEL DIAGNOSTICS: ALL 10 QUESTIONNAIRES ####
# reads: artifacts/model_fits.rds, artifacts/questionnaire_specs.rds · writes: output/diagnostic.pdf

model_fits          <- readRDS(file.path(artifacts_dir, "model_fits.rds"))
questionnaire_specs <- readRDS(file.path(artifacts_dir, "questionnaire_specs.rds"))

# One summary-table page + trankplot + pairs plot per model, in domain-table
# order. Reported without interpretation, per 02_diagnostics.md.
pdf(file.path(output_dir, "diagnostic.pdf"), width = 8, height = 6)

for (i in seq_len(nrow(questionnaire_specs))) {
  q_name  <- questionnaire_specs$questionnaire[i]
  q_label <- questionnaire_specs$label[i]

  draws <- as_draws_array(model_fits[[q_name]])

  summary_table <- summarise_draws(draws, ess_bulk, ess_tail, rhat)
  summary_table[-1] <- round(summary_table[-1], 2)

  trank_plot <- mcmc_rank_overlay(draws)
  pairs_plot <- mcmc_pairs(draws)

  grid.arrange(tableGrob(summary_table), top = q_label)
  print(trank_plot)
  print(pairs_plot)
}

dev.off()

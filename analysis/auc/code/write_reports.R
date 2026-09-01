#### RESULTS PARAGRAPH + CUTOFF METHODOLOGY NOTE ####
# reads: artifacts/roc_stats.rds, artifacts/pairwise_auc_comparisons.rds
# writes: output/results_paragraph.md, output/cutoff_methodology_note.md

roc_stats <- readRDS(file.path(artifacts_dir, "roc_stats.rds")) |> arrange(desc(auc))
pairwise  <- readRDS(file.path(artifacts_dir, "pairwise_auc_comparisons.rds"))

top_q    <- roc_stats |> slice(1)
bottom_q <- roc_stats |> slice(n())
icar_row <- roc_stats |> filter(questionnaire == "icar")
sig_pairs <- pairwise |> filter(significant_holm_p05)

ranking_text <- roc_stats |>
  transmute(txt = sprintf("%s (AUC = %.3f [%.3f, %.3f])", label, auc, ci_low, ci_high)) |>
  pull(txt) |>
  paste(collapse = ", ")

sig_pairs_text <- if (nrow(sig_pairs) == 0) {
  "no pairwise AUC difference survived Holm correction (all adjusted p >= .05)"
} else {
  sig_pairs |>
    transmute(txt = sprintf("%s vs. %s (ΔAUC = %.3f, Holm p = %.3g)",
                             questionnaire_1_label, questionnaire_2_label, auc_diff, p_holm)) |>
    pull(txt) |>
    paste(collapse = "; ")
}

results_paragraph <- paste0(
  "Across the ten questionnaires, discrimination between the ADHD and TD groups in this ",
  "sample (ADHD as the positive/case class) ranged from AUC = ", sprintf("%.3f", bottom_q$auc),
  " (", bottom_q$label, ") to AUC = ", sprintf("%.3f", top_q$auc), " (", top_q$label, "). ",
  "Full per-questionnaire AUCs with 95% DeLong confidence intervals were: ", ranking_text, ". ",
  "For ICAR, the direction of association found by pROC's automatic direction search was: ",
  icar_row$direction_label, " in this sample. ",
  "Pairwise DeLong comparisons of AUC on common-case subsamples, Holm-corrected across all 45 ",
  "pairs, indicated the following significant difference(s) at adjusted p < .05: ", sig_pairs_text, ". ",
  "These AUC values describe each questionnaire's ability to discriminate the ADHD and TD ",
  "groups within this sample; they should not be read as evidence of causal relationships, nor ",
  "as proof that any questionnaire diagnoses ADHD, and pairwise AUC differences not confirmed by ",
  "the DeLong tests above should not be over-interpreted as meaningfully different."
)

writeLines(results_paragraph, file.path(output_dir, "results_paragraph.md"))

cutoff_methodology_note <- paste0(
  "## Cutoff methodology note\n\n",
  "For each questionnaire, the 'Optimal ROC cutoff' reported in `roc_summary_table.csv` was ",
  "selected by maximizing Youden's J statistic (sensitivity + specificity - 1) on this sample's ",
  "own ROC curve (`pROC::coords(..., x = \"best\", best.method = \"youden\")`). This is a ",
  "data-derived cutoff that is optimal for discriminating ADHD from TD specifically within this ",
  "sample.\n\n",
  "This is reported separately from, and should not be assumed to equal, the 'Literature-based ",
  "cutoff' column, which reproduces a previously published clinical threshold for the seven ",
  "questionnaires that have one (ASRS >= 40, WURS >= 36, BDI >= 14, OCI-R >= 21, PQ-B >= 7, ",
  "STAI-State >= 40, STAI-Trait >= 44). AQ, PATAS, and ICAR have no established literature-based ",
  "cutoff and are left blank in that column.\n\n",
  "The two cutoffs serve different purposes: the Youden cutoff is this sample's empirical ",
  "discrimination optimum, while the literature cutoff is an externally validated clinical ",
  "threshold derived from other samples/populations. Sensitivity, specificity, PPV, and NPV in ",
  "the outputs are reported only at the Youden cutoff, and PPV/NPV in particular are computed at ",
  "this case-control sample's own prevalence rather than an external epidemiological prevalence, ",
  "so they should not be read as generalizable diagnostic probabilities."
)

writeLines(cutoff_methodology_note, file.path(output_dir, "cutoff_methodology_note.md"))

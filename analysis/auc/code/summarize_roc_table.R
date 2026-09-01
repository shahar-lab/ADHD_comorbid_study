#### SUMMARY TABLE: PER-QUESTIONNAIRE ROC STATISTICS ####
# reads: artifacts/roc_stats.rds · writes: output/roc_summary_table.csv, output/roc_sample_sizes.csv

roc_stats <- readRDS(file.path(artifacts_dir, "roc_stats.rds"))

# Main summary table, exact columns per spec
roc_summary_table <- roc_stats |>
  transmute(
    Questionnaire            = label,
    N                        = n,
    AUC                      = round(auc, 3),
    `95% CI`                 = sprintf("[%.3f, %.3f]", ci_low, ci_high),
    `p-value vs. AUC = .50`  = signif(p_value, 3),
    `Optimal ROC cutoff`     = round(youden_threshold, 2),
    Sensitivity              = round(sensitivity, 3),
    Specificity              = round(specificity, 3),
    `Literature-based cutoff` = literature_cutoff
  )

write_csv(roc_summary_table, file.path(output_dir, "roc_summary_table.csv"))

# ASSUMED[table spec lists only one N column]: N per group (N_ADHD, N_TD), PPV/NPV
# at the Youden cutoff, and the ROC direction actually used/found (relevant for
# ICAR's "auto" direction) are reported in this supplementary file rather than the
# main table, since the spec's exact column list for roc_summary_table.csv does
# not include them.
roc_sample_sizes <- roc_stats |>
  transmute(Questionnaire = label, N = n, N_ADHD = n_adhd, N_TD = n_td,
            PPV_at_optimal_cutoff = round(ppv, 3), NPV_at_optimal_cutoff = round(npv, 3),
            Direction_used = direction_used, Direction_meaning = direction_label)

write_csv(roc_sample_sizes, file.path(output_dir, "roc_sample_sizes.csv"))

cat("ICAR direction found by pROC (auto):", roc_stats$direction_label[roc_stats$questionnaire == "icar"], "\n")

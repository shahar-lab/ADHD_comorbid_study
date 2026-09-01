## Cutoff methodology note

For each questionnaire, the 'Optimal ROC cutoff' reported in `roc_summary_table.csv` was selected by maximizing Youden's J statistic (sensitivity + specificity - 1) on this sample's own ROC curve (`pROC::coords(..., x = "best", best.method = "youden")`). This is a data-derived cutoff that is optimal for discriminating ADHD from TD specifically within this sample.

This is reported separately from, and should not be assumed to equal, the 'Literature-based cutoff' column, which reproduces a previously published clinical threshold for the seven questionnaires that have one (ASRS >= 40, WURS >= 36, BDI >= 14, OCI-R >= 21, PQ-B >= 7, STAI-State >= 40, STAI-Trait >= 44). AQ, PATAS, and ICAR have no established literature-based cutoff and are left blank in that column.

The two cutoffs serve different purposes: the Youden cutoff is this sample's empirical discrimination optimum, while the literature cutoff is an externally validated clinical threshold derived from other samples/populations. Sensitivity, specificity, PPV, and NPV in the outputs are reported only at the Youden cutoff, and PPV/NPV in particular are computed at this case-control sample's own prevalence rather than an external epidemiological prevalence, so they should not be read as generalizable diagnostic probabilities.

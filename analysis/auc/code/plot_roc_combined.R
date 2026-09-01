#### COMBINED ROC PLOT: ALL 10 QUESTIONNAIRES OVERLAID ####
# reads: artifacts/roc_objects.rds, artifacts/roc_stats.rds · writes: output/roc_combined.pdf/.png

roc_objects <- readRDS(file.path(artifacts_dir, "roc_objects.rds"))
roc_stats   <- readRDS(file.path(artifacts_dir, "roc_stats.rds"))

# Paul Tol muted palette, colorblind-safe, sized for up to 10 categories (COLOR_STANDARD.md)
tol_muted <- c("#332288", "#117733", "#44AA99", "#88CCEE", "#DDCC77",
               "#CC6677", "#AA4499", "#882255", "#999933", "#44BB99")

legend_labels <- setNames(sprintf("%s (AUC = %.3f)", roc_stats$label, roc_stats$auc),
                           roc_stats$questionnaire)

combined_rows <- list()
for (q_name in roc_stats$questionnaire) {
  roc_obj <- roc_objects[[q_name]]
  combined_rows[[q_name]] <- tibble(questionnaire = q_name,
                                     fpr = 1 - roc_obj$specificities,
                                     tpr = roc_obj$sensitivities) |>
    arrange(fpr, tpr)
}

combined_df <- bind_rows(combined_rows) |>
  mutate(questionnaire_label = factor(legend_labels[questionnaire], levels = legend_labels))

p_combined <- ggplot(combined_df, aes(x = fpr, y = tpr, colour = questionnaire_label)) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", colour = "grey60") +
  geom_line(linewidth = 1) +
  scale_colour_manual(values = setNames(tol_muted, legend_labels)) +
  coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
  labs(title = "ROC curves: ADHD vs. TD discrimination by questionnaire",
       x = "1 − Specificity (False Positive Rate)", y = "Sensitivity (True Positive Rate)",
       colour = "Questionnaire (AUC)") +
  theme_minimal()

ggsave(file.path(output_dir, "roc_combined.pdf"), plot = p_combined, width = 10, height = 8, bg = "white")
ggsave(file.path(output_dir, "roc_combined.png"), plot = p_combined, width = 10, height = 8, dpi = 300, bg = "white")

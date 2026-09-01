#### INDIVIDUAL ROC PLOTS, ONE PER QUESTIONNAIRE ####
# reads: artifacts/roc_objects.rds, artifacts/roc_stats.rds · writes: output/roc_<questionnaire>.pdf/.png

roc_objects <- readRDS(file.path(artifacts_dir, "roc_objects.rds"))
roc_stats   <- readRDS(file.path(artifacts_dir, "roc_stats.rds"))

curve_colour  <- "#4477AA"  # blue, Okabe-Ito/Tol default line colour
youden_colour <- "#EE6677"  # rose, Okabe-Ito/Tol default point colour

for (q_name in roc_stats$questionnaire) {
  roc_obj <- roc_objects[[q_name]]
  stats_row <- roc_stats |> filter(questionnaire == q_name)

  curve_df <- tibble(fpr = 1 - roc_obj$specificities, tpr = roc_obj$sensitivities) |>
    arrange(fpr, tpr)
  youden_point <- tibble(fpr = 1 - stats_row$specificity, tpr = stats_row$sensitivity)

  subtitle_text <- sprintf("AUC = %.3f [95%% CI %.3f, %.3f]",
                            stats_row$auc, stats_row$ci_low, stats_row$ci_high)

  p <- ggplot(curve_df, aes(x = fpr, y = tpr)) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", colour = "grey60") +
    geom_line(colour = curve_colour, linewidth = 1) +
    geom_point(data = youden_point, aes(x = fpr, y = tpr),
               colour = youden_colour, size = 3) +
    coord_equal(xlim = c(0, 1), ylim = c(0, 1)) +
    labs(title = stats_row$label, subtitle = subtitle_text,
         x = "1 − Specificity (False Positive Rate)", y = "Sensitivity (True Positive Rate)") +
    theme_minimal()

  plot_name <- paste0("roc_", q_name)
  ggsave(file.path(output_dir, paste0(plot_name, ".pdf")), plot = p, width = 10, height = 8, bg = "white")
  ggsave(file.path(output_dir, paste0(plot_name, ".png")), plot = p, width = 10, height = 8, dpi = 300, bg = "white")
}

#### PREP BDI SEVERITY DATA ####

# Severity cutoffs are defined on the original 0-63 BDI-II scale and are the
# source of truth for classification (transformed scores are for plotting only).
severity_breaks <- c(0, 13, 19, 28, 63)
severity_labels <- c("Minimal or no depression", "Mild depression",
                      "Moderate depression", "Severe depression")

# Named df_bdi_severity (not df_bdi) to avoid colliding with the local
# df_bdi built inside plot_selfreport_dothistograms.R.
df_bdi_severity <- df |>
  filter(!is.na(bdi)) |>
  mutate(
    bdi_transformed = (bdi / 63) * 100,
    bdi_severity = cut(bdi, breaks = severity_breaks, labels = severity_labels,
                        include.lowest = TRUE, right = TRUE)
  )

cat("Rows with non-missing BDI (ADHD/TD only):", nrow(df_bdi_severity), "\n")
